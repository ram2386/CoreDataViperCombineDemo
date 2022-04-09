import CoreData

enum StorageType {
    case persistent, inMemory
}

extension NSManagedObject {
    class var entityName: String {
        return String(describing: self).components(separatedBy: ".").last!
    }

    func toJSON() -> String? {
      let keys = Array(self.entity.attributesByName.keys)
      let dict = self.dictionaryWithValues(forKeys: keys)
      do {
          let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
          let reqJSONStr = String(data: jsonData, encoding: .utf8)
          return reqJSONStr
      }
      catch{}
      return nil
    }
}

protocol EntityCreating {
    var viewContext: NSManagedObjectContext { get }
    func createEntity<T: NSManagedObject>() -> T
}

extension EntityCreating {
    func createEntity<T: NSManagedObject>() -> T {
        T(context: viewContext)
    }
}

protocol CoreDataFetchResultsPublishing {
    var viewContext: NSManagedObjectContext { get }
    func publisher<T: NSManagedObject>(fetch request: NSFetchRequest<T>) -> CoreDataFetchResultsPublisher<T>
}

extension CoreDataFetchResultsPublishing {
    func publisher<T: NSManagedObject>(fetch request: NSFetchRequest<T>) -> CoreDataFetchResultsPublisher<T> {
        return CoreDataFetchResultsPublisher(request: request, context: viewContext)
    }
}

protocol CoreDataOperationPublishing {
    var viewContext: NSManagedObjectContext { get }
    func publisher(action: ActionClosure?,
                   request: NSFetchRequest<NSFetchRequestResult>?,
                   updateName: String?,
                   operationType: OperationType) -> CoreDataOperationPublisher
}

extension CoreDataOperationPublishing {
    func publisher(action: ActionClosure?,
                   request: NSFetchRequest<NSFetchRequestResult>?,
                   updateName: String?,
                   operationType: OperationType) -> CoreDataOperationPublisher {
        return CoreDataOperationPublisher(action: action,
                                          context: viewContext,
                                          request: request,
                                          updateName: updateName,
                                          operationType: operationType)
    }
}

protocol CoreDataStoring: EntityCreating, CoreDataFetchResultsPublishing, CoreDataOperationPublishing {
    var viewContext: NSManagedObjectContext { get }
}

class CoreDataStore: CoreDataStoring {
    
    private let container: NSPersistentContainer
    
    static var `default`: CoreDataStoring = {
        return CoreDataStore(name: "ListingCoreData", in: .persistent)
    }()
    
    var viewContext: NSManagedObjectContext {
        return self.container.viewContext
    }
    
    init(name: String, in storageType: StorageType) {
        self.container = NSPersistentContainer(name: name)
        self.setupIfMemoryStorage(storageType)
        self.container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    private func setupIfMemoryStorage(_ storageType: StorageType) {
        if storageType  == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.container.persistentStoreDescriptions = [description]
        }
    }
}
