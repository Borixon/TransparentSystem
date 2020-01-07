//
//  CoreData.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 18/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//

import CoreData
import CoreStore

class CoreDataManager: NSObject {
    
    public static let shared    = CoreDataManager()
    let exceptionLogName        = "LogException"
    let actionLogName           = "LogAction"
    let timeLogName             = "LogTime"
    let dataStack               = DataStack(xcodeModelName: "TransparentSystemCD")
    var currentlySendingObjects:[NSManagedObjectID] = []
    
    override init() { }
    
    public func addObjectsToSendingPool(_ objectIDs: [NSManagedObjectID]) {
        currentlySendingObjects.append(contentsOf: objectIDs)
    }
    
    public func clearSendingPool() {
        currentlySendingObjects = []
    }
    
    public func removeObjectsFromSendingPool(_ objectIDs: [NSManagedObjectID]) {
        currentlySendingObjects = currentlySendingObjects.filter({ !objectIDs.contains($0) })
    }
    
    private func fetch(entity:String, predicate: NSPredicate? = nil) -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.predicate = predicate
        
        do {
            let objects = try managedObjectContext.fetch(request) as? [NSManagedObject]
            if objects != nil, objects!.count > 0 {
                return objects
            } else {
                return nil
            }
        } catch {
            LogManager.shared.createAndSendException(CoreDataFetchEntityException(message: entity))
            return nil
        }
    }
    
    internal func fetchPendingExceptionLogs() -> [LogException] {
        if let logs = fetch(entity: exceptionLogName, predicate: NSPredicate(format: "NOT (self.objectID IN %@)", currentlySendingObjects)) as? [LogException] {
            addObjectsToSendingPool(logs.map({ return $0.objectID }))
            print("fetched \(logs.count) logs")
            return logs
        }
        return []
    }
    
    
    internal func fetchExceptionLogs(with objectIDs: [NSManagedObjectID]) -> [LogException] {
        if let logs = fetch(entity: exceptionLogName, predicate: NSPredicate(format: "self IN %@", objectIDs)) as? [LogException] {
            return logs
        }
        return []
    }
    
    internal func fetchPendingActionLogs() -> [LogAction] {
        if let logs = fetch(entity: actionLogName, predicate: NSPredicate(format: "NOT (self.objectID IN %@)", currentlySendingObjects)) as? [LogAction] {
            addObjectsToSendingPool(logs.map({ return $0.objectID }))
            print("ferched pending actions ids \(logs.map({ return $0.objectID }))")
            return logs
        }
        return []
    }
    
    internal func fetchActionLogs(with objectIDs: [NSManagedObjectID]) -> [LogAction] {
        if let logs = fetch(entity: actionLogName, predicate: NSPredicate(format: "self IN %@", objectIDs)) as? [LogAction] {
            print("ferched actions with ids \(objectIDs) objects:\(logs.map({ return $0.objectID }))")
            return logs
        }
        return []
    }
    
    internal func fetchPendingTimeLogs() -> [LogTime] {
        if let logs = fetch(entity: timeLogName, predicate: NSPredicate(format: "endTime != nil AND NOT (self.objectID IN %@)", currentlySendingObjects)) as? [LogTime] {
            return logs
        }
        return []
    }
    
    internal func fetchTimeLogs(with objectIDs: [NSManagedObjectID]) -> [LogTime] {
        if let logs = fetch(entity: timeLogName, predicate: NSPredicate(format: "endTime != nil AND self IN %@", objectIDs)) as? [LogTime] {
            return logs
        }
        return []
    }
    
    internal func fetchAllTimeLogs() -> [LogTime]? {
        if let logs = fetch(entity: timeLogName, predicate:nil) as? [LogTime] {
            return logs
        }
        return nil
    }
    
    internal func add(exception:ExceptionLogProtocol) {
        dataStack.perform(
            asynchronous: { (transaction) -> Void in
                let exceptionEntity = transaction.create(Into<LogException>())
                exceptionEntity.name = exception.name
                exceptionEntity.message = exception.message
                exceptionEntity.timeStamp = exception.timeStamp as NSDate
                exceptionEntity.priority = Int16(exception.priority)
            },
            completion: { (result) -> Void in
                switch result {
                case .success: print("Success adding exception")
                case .failure(let error): print(error)
                }
            }
        )
    }
    
    internal func add(action:ActionLogProtocol) {
        dataStack.perform(
            asynchronous: { (transaction) -> Void in
                let actionEntity = transaction.create(Into<LogAction>())
                actionEntity.group = action.group
                actionEntity.type = action.type
                actionEntity.name = action.name
                actionEntity.value = action.value
                actionEntity.timeStamp = action.timeStamp as NSDate
            },
            completion: { (result) -> Void in
                switch result {
                case .success: print("Success adding exception")
                case .failure(let error): print(error)
                }
            }
        )
    }
    
    internal func add(enterTime:Date) {
//        let addStartOperation = MFXCoreDataOperation<AddEntryTimeLog>(data: enterTime)
//        MFXCoreDataManager.shared.addOperations(mainContext: managedObjectContext, operations: [addStartOperation], completHandler: {
//            self.saveContext(completion: {
//                // if TransparentSystem.shared.isProcessingLog == false{
//                //  LogManager.shared.checkForPendingLogs()
//                // }
//
//            })
//        })
    }
    
    internal func add(exitTime:Date) {
//        let addExitOperation = MFXCoreDataOperation<AddExitTimeLog>(data: exitTime)
//        MFXCoreDataManager.shared.addOperations(mainContext: managedObjectContext, operations: [addExitOperation], completHandler: {
//            self.saveContext(completion: {
//
//                // LogManager.shared.checkForPendingLogs()
//
//
//            })
//        })
        
    }
    
    internal func removeAllExceptions( completion:@escaping ()->Void) {
//        let removeOperation = MFXCoreDataOperation<RemoveAllPendingExceptions>(data: true)
//        MFXCoreDataManager.shared.addOperations(mainContext: managedObjectContext, operations: [removeOperation], completHandler: {
//            self.saveContext(completion: {
//
//                completion()
//
//            })
//        })
        
    }
    
    internal func removeExceptions(_ objectIDs:[NSManagedObjectID], completion:@escaping ()->Void) {
//        let removeOperation = MFXCoreDataOperation<RemovePendingExceptions>(data: objectIDs)
//        MFXCoreDataManager.shared.addOperations(mainContext: managedObjectContext, operations: [removeOperation], completHandler: {
//            self.saveContext(completion: {
//                // if result == true {
//                self.removeObjectsFromSendingPool(objectIDs)
//                completion()
//                //  }
//            })
//        })
        
    }
    
    internal func removeAllActions(completion:@escaping ()->Void) {
//        let removeOperation = MFXCoreDataOperation<RemoveAllPendingActions>(data: true)
//        MFXCoreDataManager.shared.addOperations(mainContext: managedObjectContext, operations: [removeOperation], completHandler: {
//            self.saveContext(completion: {
//
//                completion()
//
//            })
//        })
        
    }
    
    internal func removeActions(_ objectIDs:[NSManagedObjectID], completion:@escaping ()->Void) {
//        let removeOperation = MFXCoreDataOperation<RemovePendingActions>(data: objectIDs)
//        MFXCoreDataManager.shared.addOperations(mainContext: managedObjectContext, operations: [removeOperation], completHandler: {
//            self.saveContext(completion: {
//
//                self.removeObjectsFromSendingPool(objectIDs)
//                completion()
//
//            })
//        })
//
    }
    
    internal func removeTime(_ objectIDs:[NSManagedObjectID], completion:@escaping ()->Void) {
//        let removeOperation = MFXCoreDataOperation<RemovePendingTime>(data: objectIDs)
//        MFXCoreDataManager.shared.addOperations(mainContext: managedObjectContext, operations: [removeOperation], completHandler: {
//            self.saveContext(completion: {
//
//                self.removeObjectsFromSendingPool(objectIDs)
//                completion()
//
//            })
//        })
        
    }
    
    internal func removeAllTime(completion:@escaping ()->Void) {
//        let removeOperation = MFXCoreDataOperation<RemoveAllPendingTime>(data: true)
//        MFXCoreDataManager.shared.addOperations(mainContext: managedObjectContext, operations: [removeOperation], completHandler: {
//            self.saveContext(completion: {
//
//                completion()
//
//            })
//        })
        
    }
    
    internal lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TransparentSystemCD")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    public func clearAllData() {
        self.removeAllExceptions(completion: {
            
        })
        self.removeAllActions(completion: {
            
        })
        self.removeAllTime(completion: {
            
        })
    }
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        
        let bundleURL:URL
        if let url = Bundle(for: CoreDataManager.self).url(forResource: "TransparentSystem", withExtension: "bundle") {
            bundleURL = url
        } else {
            bundleURL = Bundle.main.bundleURL
        }
        
        guard let frameworkBundle = Bundle(url: bundleURL) else {
            fatalError("Unable create bundle")
        }
        guard let modelURL = frameworkBundle.url(forResource: "TransparentSystemCD", withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let persistentStoreCoordinator  = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let fileManager                 = FileManager.default
        let storeName                   = "TransparentSystemCD.sqlite"
        let documentsDirectoryURL       = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistentStoreURL          = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            let options = [ NSInferMappingModelAutomaticallyOption : true,
                            NSMigratePersistentStoresAutomaticallyOption : true]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: options)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
    
}

class CoreDataFetchEntityException: ExceptionLogProtocol {
    
    required init(name: String = "Core Data entity fetch exception", message: String, priority: Int = 1, timeStamp: Date = Date()) {
        self.name = name
        self.message = message
        self.priority = priority
        self.timeStamp = timeStamp
    }
    
    var name: String
    var message: String
    var priority: Int
    var timeStamp: Date
    
}

extension CoreDataManager {
    
    internal func fetchAllActionLogs() -> [LogAction]? {
        if let logs = fetch(entity: actionLogName, predicate:nil) as? [LogAction] {
            return logs
        }
        return nil
    }
    internal func fetchAllActionLogsMOCIDs() -> [NSManagedObjectID]? {
        if let logs = fetch(entity: actionLogName, predicate:nil) as? [LogAction] {
            return  logs.map({ return $0.objectID })
        }
        return nil
    }
    internal func fetchAllExceptionLogs() -> [LogException]? {
        if let logs = fetch(entity: exceptionLogName, predicate:nil) as? [LogException] {
            return logs
        }
        return nil
    }
    internal func fetchAllExceptionLogsMOCIDs() -> [NSManagedObjectID]? {
        if let logs = fetch(entity: exceptionLogName, predicate:nil) as? [LogException] {
            return logs.map({ return $0.objectID })
        }
        return nil
    }
    internal func fetchAllTimeLogsMOCIDs() -> [NSManagedObjectID]? {
        if let logs = fetch(entity: timeLogName, predicate:nil) as? [LogTime] {
            return logs.map({ return $0.objectID })
        }
        return nil
    }
    
}

