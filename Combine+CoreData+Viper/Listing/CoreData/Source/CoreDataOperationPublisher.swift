//
//  CoreDataOperationPublisher.swift
//  Combine+CoreData+Viper
//
//  Created by Ramkrishna Sharma on 29/03/22.
//

import Combine
import CoreData

typealias ActionClosure = (()->())

enum OperationType {
    case add
    case update
    case delete
}

struct CoreDataOperationPublisher: Publisher {
    class Subscription<S> where S : Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private let action: ActionClosure?
        private let context: NSManagedObjectContext
        private let request: NSFetchRequest<NSFetchRequestResult>?
        private let updateName: String?
        private let operationType: OperationType

        init(subscriber: S,
             context: NSManagedObjectContext,
             action: ActionClosure?,
             request: NSFetchRequest<NSFetchRequestResult>?,
             updateName: String?,
             operationType: OperationType) {
            self.subscriber = subscriber
            self.context = context
            self.action = action
            self.request = request
            self.updateName = updateName
            self.operationType = operationType
        }
    }

    typealias Output = Bool
    typealias Failure = NSError

    private let action: ActionClosure?
    private let context: NSManagedObjectContext
    private let request: NSFetchRequest<NSFetchRequestResult>?
    private let updateName: String?
    private let operationType: OperationType

    init(action: ActionClosure?,
         context: NSManagedObjectContext,
         request: NSFetchRequest<NSFetchRequestResult>?,
         updateName: String?,
         operationType: OperationType) {
        self.action = action
        self.context = context
        self.request = request
        self.updateName = updateName
        self.operationType = operationType
    }

    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(subscriber: subscriber,
                                        context: context,
                                        action: action,
                                        request: request,
                                        updateName: updateName,
                                        operationType: operationType)
        subscriber.receive(subscription: subscription)
    }
}

extension CoreDataOperationPublisher.Subscription: Subscription {
    func request(_ demand: Subscribers.Demand) {
        var demand = demand
        guard let subscriber = subscriber, demand > 0 else { return }

        do {
            demand -= 1
            if operationType == .add {
                action?()
                try context.save()
                demand += subscriber.receive(true)
            } else if operationType == .update {
                let updateRecords = try context.fetch(request!)
                if updateRecords.count > 0 {
                    let objectUpdate = updateRecords[0] as! NSManagedObject
                    objectUpdate.setValue(updateName, forKey: "fullName")
                    try context.save()
                    demand += subscriber.receive(true)
                }
            } else {
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request!)
                batchDeleteRequest.resultType = .resultTypeCount
                if let _ = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult {
                    demand += subscriber.receive(true)
                }
                else {
                    subscriber.receive(completion: .failure(NSError()))
                }
            }
        } catch {
            subscriber.receive(completion: .failure(error as NSError))
        }
    }
}

extension CoreDataOperationPublisher.Subscription: Cancellable {
    func cancel() {
        subscriber = nil
    }
}
