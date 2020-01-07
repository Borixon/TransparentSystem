//
//  LogProtocol.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 28/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//

import Foundation
 
public protocol ExceptionLogProtocol {
    init(name:String, message:String, priority:Int, timeStamp: Date)
    var name:String { get set }
    var message:String { get set }
    var priority:Int { get set }
    var timeStamp:Date { get set }
}


public protocol ActionLogProtocol {
    init(group:String, type:String, name:String, value:String, timeStamp: Date)
    var group:String { get set }
    var type:String { get set }
    var name:String { get set }
    var value:String { get set }
    var timeStamp:Date { get set }
}

public protocol TimeLogProtocol {
    var dateStart:Date? { get set }
    var dateEnd:Date? { get set }
}

class FailGetTokenLogException:ExceptionLogProtocol {
    required init(name: String = "Exception getting BS token", message: String, priority: Int = 1, timeStamp: Date = Date()) {
        self.name = name
        self.timeStamp = timeStamp
        self.priority = priority
        self.message = message
    }
    var name: String
    var message: String
    var priority: Int
    var timeStamp: Date
}

class JSONParsingLogException:ExceptionLogProtocol {
    required init(name: String = "Exception parsing JSON", message: String, priority: Int = 1, timeStamp: Date = Date()) {
        self.name = name
        self.timeStamp = timeStamp
        self.priority = priority
        self.message = message
    }
    var name: String
    var message: String
    var priority: Int
    var timeStamp: Date
}

/**
 Przykładowy sposób stworzenia obiektu błędu z danymi
 */
class ExcampleBadGateWay:ExceptionLogProtocol {
    
    var name: String        = "HTTP 502...504"
    var message: String     = "BadGateWay"
    var priority: Int       = 1
    var timeStamp: Date     = Date()
    
    required init(name: String = "HTTP 502...504", message: String = "BadGateWay", priority: Int = 1, timeStamp: Date = Date()) {
        self.name = name
        self.message = message
        self.priority = priority
        self.timeStamp = timeStamp
    }
    
}

