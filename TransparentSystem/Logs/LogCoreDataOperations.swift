//
//  addTimeLog.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 18/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//

import Foundation
import CoreData


class AddEntryTimeLog {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: Date) {
        let object = LogTime(context: context)
        object.startTime = data as NSDate?
        print("Did add enter Log")
    }
}

class AddExitTimeLog {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: Date) {
//        if let logs = fetch(forContext: context, entityName: "LogTime") as? [LogTime] {
//            // print("log first \(logs.first?.startTime) \(logs.first?.endTime)")
//            if let filtered = logs.filter({ $0.endTime == nil }).first {
//                filtered.endTime = data as NSDate?
//                Logger. print("Did complete time Log \(String(describing: filtered.startTime)) \(String(describing: filtered.endTime))")
//            } else {
//
//            }
//        }
    }
}

class AddExceptionLog {
    required init(){
        
    }
    func execute(forContext context: NSManagedObjectContext, data: ExceptionLogProtocol) {
        let object = LogException(context: context)
        object.name = data.name
        object.message = data.message
        object.priority = Int16(data.priority)
        object.timeStamp = data.timeStamp as NSDate
    }
}

class AddActionLog {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: ActionLogProtocol) {
        let object = LogAction(context: context)
        object.name = data.name
        object.group = data.group
        object.type = data.type
        object.value = data.value
        object.timeStamp = data.timeStamp as NSDate
    }
}

class RemovePendingExceptions {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: [NSManagedObjectID]) {
        for objID in data {
            context.delete(context.object(with: objID))
        }
    }
}

class RemoveAllPendingExceptions {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: Bool) {
//        if let logs = fetch(forContext: context, entityName: "LogException") as? [LogException] {
//            for obj in logs {
//                context.delete(obj)
//            }
//        }
    }
}

class RemovePendingActions {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: [NSManagedObjectID]) {
        for objID in data {
            context.delete(context.object(with: objID))
        }
    }
}

class RemoveAllPendingActions {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: Bool) {
        guard data == true else {return}
//        if let logs = fetch(forContext: context, entityName: "LogAction") as? [LogAction] {
//            for obj in logs {
//                context.delete(obj)
//            }
//        }
    }
}

class RemovePendingTime {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: [NSManagedObjectID]) {
        for objID in data {
            context.delete(context.object(with: objID))
        }
    }
}

class RemoveAllPendingTime {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: Bool) {
        guard data == true else { return }
//        if let logs = fetch(forContext: context, entityName: "LogTime") as? [LogTime] {
//            for obj in logs {
//                context.delete(obj)
//            }
//        }
    }
}

class SaveContext {
    required init(){}
    func execute(forContext context: NSManagedObjectContext, data: Bool) {
        if context.hasChanges {
            do {
                try context.save()
                Logger.print("Core Data save Success")
            } catch {
                LogManager.shared.createAndSendException(CoreDataSaveException())
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

class CoreDataEntityRemoveException: ExceptionLogProtocol {
    
    required init(name: String, message: String, priority: Int, timeStamp: Date) {
        self.name = name
        self.message = message
        self.priority = priority
        self.timeStamp = timeStamp
    }
    
    var name: String = ""
    var message: String = ""
    var priority: Int = 0
    var timeStamp: Date = Date()
    
}

class CoreDataSaveException: ExceptionLogProtocol {
    
    init() {
        self.name = "Core Data Exception"
        self.message = "Core Data saving context exception"
        self.priority = 1
        self.timeStamp = Date()
    }
    
    required init(name: String, message: String, priority: Int, timeStamp: Date) {
        self.name = "Core Data Exception"
        self.message = "Core Data saving context exception"
        self.priority = 1
        self.timeStamp = Date()
    }
    
    var name: String
    var message: String
    var priority: Int
    var timeStamp: Date
    
}
