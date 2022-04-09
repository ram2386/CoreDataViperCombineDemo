//
//  ListingInteractor.swift
//  Combine+CoreData+Viper
//
//  Created by Ramkrishna Sharma on 27/03/22.
//

import Foundation
import Combine
import CoreData

class ListingInteractor: PresenterToInteractorProtocol {
    var bag: [AnyCancellable] = []
    var coreDataStore: CoreDataStoring!
    var presenter: InteractorToPresenterProtocol?

    func fetch() {
        let request = NSFetchRequest<Person>(entityName: Person.entityName)
        coreDataStore
            .publisher(fetch: request)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { persons in
                print("Records: \(persons.count)")
                let listingRecords = self.convertNSManagedToModel(records: persons, using: [ListingModel].self)!
                self.presenter?.fetchedSuccess(listingModelArray: listingRecords)
            }
            .store(in: &bag)
    }

    func addPerson(fullName: String) {
        guard !fullName.isEmpty else { return }
        let action: ActionClosure = {
            let bezo: Person = self.coreDataStore.createEntity()
            bezo.fullName = fullName
        }
        coreDataStore
            .publisher(action: action, request: nil, updateName: nil, operationType: .add)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { success in
                if success {
                    print("Success")
                    self.fetch()
                }
            }
            .store(in: &bag)
    }

    func updatePerson(fullName: String, searchFullName: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Person.entityName)
        request.predicate = NSPredicate(format: "fullName LIKE[cd] %@", searchFullName)
        coreDataStore
            .publisher(action: nil, request: request, updateName: fullName, operationType: .update)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { _ in
                print("Update")
                self.fetch()
            }
            .store(in: &bag)
    }

    func deletePerson(fullName: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Person.entityName)
        request.predicate = NSPredicate(format: "fullName LIKE[cd] %@", fullName)
        coreDataStore
            .publisher(action: nil, request: request, updateName: nil, operationType: .delete)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { _ in
                print("Delete")
                self.fetch()
            }
            .store(in: &bag)
    }

    func convertNSManagedToModel<T: Decodable>(records: [NSManagedObject], using modelType: T.Type) -> T? {
        var recordArray: [[String: Any]] = []
        for item in records {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            recordArray.append(dict)
        }
        do {
            let json = try JSONSerialization.data(withJSONObject: recordArray)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedList = try decoder.decode(modelType, from: json)
            return decodedList
        } catch {
            print("Error in decoding: \(error.localizedDescription)")
            return nil
        }
    }
}
