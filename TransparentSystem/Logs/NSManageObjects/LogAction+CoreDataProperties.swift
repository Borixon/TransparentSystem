//
//  LogAction+CoreDataProperties.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 28/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//
//

import Foundation
import CoreData


extension LogAction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogAction> {
        return NSFetchRequest<LogAction>(entityName: "LogAction")
    }
 
    @NSManaged public var group: String?
    @NSManaged public var name: String?
    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var type: String?
    @NSManaged public var value: String?

}


