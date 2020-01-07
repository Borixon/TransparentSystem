//
//  LogCreator.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 18/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration
import SwiftyJSON
import CoreData

@objc public enum LogTimeType:Int {
    case start
    case end
}

class LogManager: NSObject {
    
    static let shared = LogManager()

    let systemType      = "iOS"
    let deviceName      = UIDevice.modelName
    let deviceType      = UIDevice.current.localizedModel
    let systemVersion   = UIDevice.current.systemVersion
    let systemName      = UIDevice.current.systemName
    let appVersion      = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    
    lazy var dateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatter
    }()
    
    var isTokenValid: Bool {
        if Defaults().tokenExpirationDate < Date() {
            Logger.print("Token is invalid")
            return false
        }
        Logger.print("Token is valid")
        return true
    }
    
    private let customQueue = DispatchQueue(label: "CheckValidTokenOperationQueue")
    
    private let functionSemaphore = DispatchSemaphore(value: 1)
    //Long task download in background //
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    func endBackgroundTask() {
        Logger.print("Background task ended")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    /** MARK: MOje podejscie do tematu, oparte o backgroundTask, notifikacja z appdelegeja zeby odpalic*/
    
    public func sendLogsToBSInBackgroundTask() {
        DispatchQueue.global().async {
            self.registerBackgroundTask()
            guard Defaults().userEmail != "NilUser" else {self.endBackgroundTask()
                Logger.print("User is not defined")
                return }
            guard Reachability().isConnected else { self.endBackgroundTask()
                Logger.print("No internet connection")
                return }
            
            self.customQueue.sync{ [unowned self] in
                
                self.functionSemaphore.wait()
                
                let exceptionLogs =  CoreDataManager.shared.fetchAllExceptionLogsMOCIDs()
                let actionLogs = CoreDataManager.shared.fetchAllActionLogsMOCIDs()
                let timeLogs = CoreDataManager.shared.fetchAllTimeLogsMOCIDs()
        
                Logger.print("Should send pending Logs")
                
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                self.checkToken(completion: {
                    dispatchSemaphore.signal()
                })
                dispatchSemaphore.wait()
                
                if exceptionLogs?.count ?? 0 > 0 {
                    Logger.print("Sending Exceptions")
                    self.sendExceptions(with: exceptionLogs!, completion: { success in
                        
                    })
                }
                
                if actionLogs?.count ?? 0 > 0 {
                    Logger.print("Sending Actions")
                    
                    self.sendActions(with: actionLogs!, completion: {_ in
                        
                    })
                }
                
                if timeLogs?.count ?? 0 > 0 {
                    Logger.print("Sending Time")
                    self.sendTime(with: timeLogs!, completion: {_ in
                        
                    })
                }
                
                self.functionSemaphore.signal()
            }
            
            if self.backgroundTask != .invalid {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.endBackgroundTask()
                }
            }
            
        }
    }

    private func checkToken(completion:@escaping() -> (Void)) {
        guard Reachability().isConnected else {
            return }
        if !self.isTokenValid {
            
            NetworkManager().getToken(completion: { finish in
                completion()
            })
        } else {
            completion()
        }
    }
    
    public func createAndSendException<T:ExceptionLogProtocol>(_ log:T) {
        
        guard let currentException = createJson(exception: log).dictionaryObject else {
            CoreDataManager.shared.add(exception: log)
            return
        }
        
        let networkMng = NetworkManager()
        networkMng.currentException = currentException
        
        checkToken(completion: {
            networkMng.sendException(exc: currentException, completion: { success in
                if !success {
                    CoreDataManager.shared.add(exception: log)
                } else {
                    
                }
            })
        })
        
    }
    
    public func createExceptionLog<T:ExceptionLogProtocol>(_ log:T) {
        CoreDataManager.shared.add(exception: log)
    }
    
    public func createActionLog<T:ActionLogProtocol>(_ log:T) {
        CoreDataManager.shared.add(action: log)
    }
    
    public func createTimeLog(date:Date, type:LogTimeType ) {
        if type == .start {
            CoreDataManager.shared.add(enterTime: date)
        } else {
            CoreDataManager.shared.add(exitTime: date)
        }
        
    }
    
    private func sendExceptions(with objectIDs: [NSManagedObjectID], completion: @escaping (_ success:Bool) -> ())  {
        guard Reachability().isConnected else {
            return }
        NetworkManager().sendExceptions(with: objectIDs, completion: { success in
            if success {
                CoreDataManager.shared.removeExceptions(objectIDs, completion: {
                    completion(true)
                })
            }else{
                completion(false)
            }
        })
    }
    
    private func sendActions(with objectIDs: [NSManagedObjectID], completion: @escaping (_ success:Bool) -> ()) {
        guard Reachability().isConnected else {
            return }
        NetworkManager().sendActions(with: objectIDs, completion: { success in
            if success {
                CoreDataManager.shared.removeActions(objectIDs, completion: {
                    completion(true)
                })
            }else{
                completion(false)
            }
        })
    }
    
    private func sendTime(with objectIDs: [NSManagedObjectID], completion: @escaping (_ success:Bool) -> ()) {
        guard Reachability().isConnected else {
            return }
        
        NetworkManager().sendTime(with: objectIDs, completion: { success in
            if success {
                CoreDataManager.shared.removeTime(objectIDs, completion: {
                    
                })
            }else{
                completion(false)
            }
        })
    }
    
    private func basicLogJson() -> JSON {
        let data = JSON(["systemType":systemType,
                         "systemVersion":systemVersion,
                         "deviceName":deviceName,
                         "appVersion":appVersion,
                         "userEmail":Defaults().userEmail])
        return data
    }
    
    public func getExceptionBody(with IDs:[NSManagedObjectID]) -> Dictionary<String, Any> {
        let logs = CoreDataManager.shared.fetchExceptionLogs(with: IDs)
        if logs.count > 0 {
            guard let dictionary = exceptionLogsJson(from: logs).dictionaryObject else { return ["":""] }
            return dictionary
        }
        return ["":""]
    }
    
    public func getActionBody(with IDs:[NSManagedObjectID]) -> Dictionary<String, Any> {
        let logs = CoreDataManager.shared.fetchActionLogs(with: IDs)
        print(IDs)
        if logs.count > 0 {
            guard let dictionary = actionLogsJson(from: logs).dictionaryObject else { return ["":""] }
            return dictionary
        }
        return ["":""]
    }
    
    public func getTimeBody(with IDs:[NSManagedObjectID]) -> Dictionary<String, Any> {
        let logs = CoreDataManager.shared.fetchTimeLogs(with: IDs)
        if logs.count > 0 {
            guard let dictionary = timeLogsJson(from: logs).dictionaryObject else { return ["":""] }
            return dictionary
        }
        return ["":""]
    }
    
    internal func exceptionLogsJson(from entities:[LogException]) -> JSON {
        var basic = basicLogJson()
        var array = [JSON]()
        for e in entities {
            let json = JSON(["name":e.name!,
                             "message":e.message!,
                             "priority":String(e.priority),
                             "timestamp":Int(e.timeStamp!.timeIntervalSince1970)])
            array.append(json)
        }
        basic["data"] = JSON(array)
        return basic
    }
    
    internal func actionLogsJson(from entities:[LogAction]) -> JSON {
        var basic = basicLogJson()
        var array = [JSON]()
        for e in entities {
            guard e.group != nil, e.name != nil, e.type != nil, e.value != nil, e.timeStamp != nil else {
                break }
            let json = JSON(["group":e.group!,
                             "type":e.type!,
                             "name":e.name!,
                             "value":e.value!,
                             "timestamp":Int(e.timeStamp!.timeIntervalSince1970)])
            array.append(json)
        }
        basic["data"] = JSON(array)
        print(basic)
        return basic
    }
    
    internal  func timeLogsJson(from entities:[LogTime]) -> JSON {
        var basic = basicLogJson()
        var array = [JSON]()
        for e in entities {
            var json = JSON(["start":String(Int(e.startTime!.timeIntervalSince1970))])
            if let _ = e.endTime {
                json["end"] = JSON(String(Int(e.endTime!.timeIntervalSince1970)))
            } else {
                json["end"] = JSON("NULL")
            }
            array.append(json)
        }
        basic["data"] = JSON(array)
        return basic
    }
    
    private func createJson<T:ExceptionLogProtocol>(exception:T) -> JSON {
        var json = basicLogJson()
        
        let dataJson = JSON(["name":exception.name,
                             "message":exception.message,
                             "priority":String(exception.priority),
                             "timestamp":Int(exception.timeStamp.timeIntervalSince1970)])
        json["data"] = [dataJson]
        return json
    }
}

class Reachability {
    var isConnected:Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}

extension LogManager{
    public enum Errors: Error {
        case invalidData(String?)
        case invalidEndpoint(String?)
        case canceled(String?)
        case invalidSave(String?)
    }
}
