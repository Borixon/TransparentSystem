//
//  TransparentSystem.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 11/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

@objc public class TransparentSystem: NSObject {
    
    @objc public static let shared:TransparentSystem = TransparentSystem()
    
    public override init() {
        super.init()
    }
    internal var isProcessingLog = false
    /**
     Dodanie loga z czasem zalogowania i wylogowania
     */
    @objc private func log(time:Date, type:LogTimeType) {
        LogManager.shared.createTimeLog(date: time, type: type)
    }
    
    /**
     Dodanie loga z błędem. Przy dodaniu loga tego typu następuje próba wysłania go do API, a w przypadku niepowodzenia, zostaje on zapisany do bazy Core Data
     */
    public func log<T:ExceptionLogProtocol>(_ excObject:T) {
        LogManager.shared.createAndSendException(excObject)
    }
    
    /**
     Dodanie loga z akcją
     */
    public func log<T:ActionLogProtocol>(_ actObject:T) {
        LogManager.shared.createActionLog(actObject)
    }
    
    /**
     Czyści dane z core data
     */
    @objc public func clearAllData() {
        CoreDataManager.shared.clearAllData()
    }
    
    /**
     Ustawianie wersji api. Domyślnie na '/api/v1'
     */
    @objc public func set(apiVersion:String) {
        Defaults().apiVersion = apiVersion
    }
    
    /**
     Funkcja dodawania logów akcji dla aplikacji napisanych w Objective-C
     */
    @objc public func logAction(group:String, type:String, name:String, value:String) {
        self.log(ObjcActionLog(group: group, type: type, name: name, value: value, timeStamp: Date()))
    }
    
    /**
     Funkcja dodawania logów błędów dla aplikacji napisanych w Objective-C
     */
    @objc public func logException(name:String, message:String, priority:Int) {
        self.log(ObjcExceptionLog(name: name, message: message, priority: priority, timeStamp: Date()))
    }
    
    /**
     Podstawowa konfiguracja BS.
     
     - Parameters:
         - credentials: pole z sekretem i stringiem potrzebnym do uzyskania właściwego tokenu. Ważność tokenu to 15 minut. Należy sprawdzać go przy wchodzeniu do aplikacji
         - environment: określa endpoint
         - userEmail: pole potrzebne do identyfikacji użytkownika
         - maxLogNumber: określa maksymalną ilość logów po której zostaną one wysłane na serwer
     */
    @objc public func configure(environment: TSEnvironment, userEmail:String? = nil, maxLogNumber:Int = 5) {
        
        set(numOfMaxLogs: maxLogNumber)
        set(environment: environment)
        
        if userEmail != nil {
            set(userEmail: userEmail!)
        }
        
        setupObservers()
        
    }
    
    /**
     Ustawienie adresu email usera
     */
    @objc public func set(userEmail:String) {
        Defaults().userEmail = userEmail
    }
    
    /**
     Maksymalna liczba logów po której przekroczeniu zostaną wysłane na serwer
     */
    @objc public func set(numOfMaxLogs:Int) {
        Defaults().maxLogNumber = numOfMaxLogs
    }
    
    /**
     Ustawienie zmiennej do pokazywania logów TransparentSystem
     */
    @objc public func set(showLogs:Bool) {
        Defaults().showLogs = showLogs
    }
    
    /**
     Ustawienie zmiennej do pokazywania logów operacji networkingu w BS
     */
    @objc public func set(showNetworkLogs:Bool) {
        Defaults().showNetworkLogs = showNetworkLogs
    }
    
    /**
     Ustawienie bazowego url
     */
    @objc public func set(url:String) {
        if URL(string: url) != nil {
            Defaults().baseURL = url
        }
    }
    
    /**
     Ustawienie bazowego url za pośrednictwem enuma środowiskowego
     */
    @objc public func set(environment:TSEnvironment) {
        switch environment {
        case .development:
            Defaults().baseURL = "https://DEVTransparentSystem.pl"
            break
        case .releaseCandidate:
            Defaults().baseURL = "https://RCTransparentSystem.pl"
            break
        case .production:
            Defaults().baseURL = "https://TransparentSystem.pl"
        }
    }
    
    /**
     Pomocnicza funkcja do wyswietlania logow w postaci JSONa. Musi być aktywa zmienna w funkcji set(showLogs)
     */
    @objc public func printPendingLogs() {
        
        var json = JSON() 
        let exceptionLogs = CoreDataManager.shared.fetchPendingExceptionLogs()
        if exceptionLogs.count > 0 {
            json["exceptions"] = LogManager.shared.exceptionLogsJson(from: exceptionLogs)
        }
        let actionLogs = CoreDataManager.shared.fetchPendingActionLogs()
        if actionLogs.count > 0 {
            json["actions"] = LogManager.shared.actionLogsJson(from: actionLogs)
        }
        let timeLogs = CoreDataManager.shared.fetchPendingTimeLogs()
        if timeLogs.count > 0 {
            json["time"] = LogManager.shared.timeLogsJson(from: timeLogs)
        }
        Logger.print("\n************ PENDING LOGS ************\n\(json)\n*************************************\n")
        
    }
    
    /**
     Dodanie niezbędnych obserwatorów dla aplikacji, wykrywających wejście do apki, wejścia w tło oraz zamknięcie
     */
    private func setupObservers() {
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: app)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminateOrEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: app)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminateOrEnterBackground), name: UIApplication.willTerminateNotification, object: app)
        NotificationCenter.default.addObserver(self, selector: #selector(sendLogs), name: Notification.Name("sendLogs"), object: nil)
    }
 
    /**
     Sprawdzenie czy token jest poprawny oraz czy istnieją logi do wysłania. Funkcję najlepiej umieszczać w AppDelegate.appDidBecomeActive
     */
    @objc public func checkValidToken() {
        if !LogManager.shared.isTokenValid {
            NetworkManager().getToken(completion: { finish in
                
            })
        }
    }
    @objc public func sendLogs() {
        Logger.print("sendLogs")
        LogManager.shared.sendLogsToBSInBackgroundTask()
        
    }
    
    @objc public func appWillTerminateOrEnterBackground() {
        Logger.print("appWillTerminateOrEnterBackground")
        log(time: Date(), type: .end)
    }
    
    @objc public func appWillTerminate() {
        Logger.print("appWillTerminate")
        
        log(time: Date(), type: .end)
        LogManager.shared.sendLogsToBSInBackgroundTask()
    }
    
    @objc public func appDidBecomeActive() {
        Logger.print("appDidBecomeActiveOrEnterForeground")
        log(time: Date(), type: .start)
    }
    
}

class ObjcActionLog:ActionLogProtocol {
    required init(group: String, type: String, name: String, value: String, timeStamp: Date) {
        self.group = group
        self.type = type
        self.name = name
        self.value = value
        self.timeStamp = timeStamp
    }
    
    var group: String
    var type: String
    var name: String
    var value: String
    var timeStamp: Date
}

class ObjcExceptionLog:ExceptionLogProtocol {
    required init(name: String, message: String, priority: Int, timeStamp: Date) {
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

@objc public enum TSEnvironment: Int {
    case development
    case releaseCandidate
    case production
}

