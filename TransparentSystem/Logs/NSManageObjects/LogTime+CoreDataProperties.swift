//
//  LogTime+CoreDataProperties.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 24/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//
//

import Foundation
import CoreData


extension LogTime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogTime> {
        return NSFetchRequest<LogTime>(entityName: "LogTime")
    }
 
    @NSManaged public var endTime: NSDate?
    @NSManaged public var startTime: NSDate?

}
