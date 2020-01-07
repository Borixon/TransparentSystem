//
//  LogException+CoreDataProperties.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 28/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//
//

import Foundation
import CoreData


extension LogException {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogException> {
        return NSFetchRequest<LogException>(entityName: "LogException")
    }
 
    @NSManaged public var message: String?
    @NSManaged public var name: String?
    @NSManaged public var priority: Int16
    @NSManaged public var timeStamp: NSDate?

}

