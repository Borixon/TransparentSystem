//
//  Logger.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 06/03/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//

import UIKit


class Logger: NSObject {
    
    func printSendException<T:ExceptionLogProtocol>(_ log:T, success:Bool) {
        guard Defaults().showLogs else { return }
        var exception = "\n[TransparentSystem]" + (success ? "Did send:" : "Could not send:")
        exception.append("\nException\nName: \(log.name)\nMessage: \(log.message)\nPriority: \(log.priority)\nUnix time stamp: \(log.timeStamp)")
        Logger.print(exception)
    }
    
    func printLog(_ exceptionLogProtocol:ExceptionLogProtocol) {
        guard Defaults().showLogs else { return }
        var exception = "\n[TransparentSystem] Did add 'Exception log' to Core Data:"
        exception.append("\nName: \(exceptionLogProtocol.name)\nMessage: \(exceptionLogProtocol.message)\nPriority: \(exceptionLogProtocol.priority)\nUnix time stamp: \(exceptionLogProtocol.timeStamp)")
        Logger.print(exception)
    }
    
    func printAddAction<T:ActionLogProtocol>(_ log:T) {
        guard Defaults().showLogs else { return }
        let exception = "\n[TransparentSystem] Did add 'Action log' to Core Data:\nGroup: \(log.group)\nName: \(log.name)\nType: \(log.type)\nValue: \(log.value)\nUnix time stamp: \(log.timeStamp)"
        Logger.print(exception)
        
    }
    
    func printAddTime<T:TimeLogProtocol>(_ log:T) {
        guard Defaults().showLogs else { return }
        let exception = "\n[TransparentSystem] Did add 'Time log' to Core Data:\nEnter: \(String(describing: log.dateStart))\nExit: \(String(describing: log.dateEnd))"
        Logger.print(exception)
    }
    
    public static func print(_ string:String) {
        guard Defaults().showLogs else { return }
        print("TransparentSystem: " + string)
    }
}
