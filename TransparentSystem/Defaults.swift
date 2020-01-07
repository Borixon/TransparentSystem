//
//  Defaults.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 17/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//

import Foundation

/**
    Klasa do przechowywania adresów endpointów.
    Przed wykorzystaniem należy ustalić bazowy url do API,
    endpointy są zdefiniowane domyślnie ale można je nadpisywać
 */
public class Defaults: NSObject {
    
    private let standard = UserDefaults.standard
   
    /**
     Bazowe url w API. Przed wyciagnięciem wartości należy wpisać adres
     */
    private let kBaseURL = "DefaultsBaseURL"
    public var baseURL: String {
        get {
            if standard.value(forKey: kBaseURL) == nil { 
                return ""
            } else {
                return standard.value(forKey: kBaseURL) as! String
            }
        }
        set {
            standard.set(newValue, forKey: kBaseURL)
        }
    }
    
    private let kMaxLogNumber = "DefaultsMaxLogNumber"
    public var maxLogNumber: Int {
        get {
            if standard.value(forKey: kMaxLogNumber) == nil {
                return 5
            } else {
                return standard.value(forKey: kMaxLogNumber) as! Int
            }
        }
        set {
            standard.set(newValue, forKey: kMaxLogNumber)
        }
    }
      
    /**
     Wersja api w formacie '/api/vX' gdzie X to numer Api
     */
    private let kApiVersion = "DefaultsAPIVersion"
    public var apiVersion: String {
        get {
            if standard.value(forKey: kApiVersion) == nil {
                return "1"
            } else {
                return standard.value(forKey: kApiVersion) as! String
            }
        }
        set {
            standard.set(newValue, forKey: kApiVersion)
        }
    }
    
    private let kExceptionEndpoint = "DefaultsExceptionEndpoint"
    public var exceptionEndpoint: String {
        get{
            if standard.value(forKey: kExceptionEndpoint) == nil {
                return "/log/exception"
            } else {
                return standard.value(forKey: kExceptionEndpoint) as! String
            }
        }
        set{
            standard.set(newValue, forKey: kExceptionEndpoint)
        }
    }
    
    private let kTimeEndopoint = "DefaultsTimeEndpoint"
    public var timeEndopoint: String {
        get{
            if standard.value(forKey: kTimeEndopoint) == nil {
                return "/log/time"
            } else {
                return standard.value(forKey: kTimeEndopoint) as! String
            }
        }
        set{
            standard.set(newValue, forKey: kTimeEndopoint)
        }
    }
    
    private let kActionEndpoint = "DefaultsActionEndpoint"
    public var actionEndopoint: String {
        get{
            if standard.value(forKey: kActionEndpoint) == nil {
                return "/log/action"
            } else {
                return standard.value(forKey: kActionEndpoint) as! String
            }
        }
        set{
            standard.set(newValue, forKey: kActionEndpoint)
        }
    }
    
    private let kLastTimeSend = "DefaultsLastTimeSend"
    public var lastTimeSend: Date {
        get{
            if standard.value(forKey: kLastTimeSend) == nil {
                standard.set(Date(), forKey: kLastTimeSend)
                return standard.value(forKey: kLastTimeSend) as! Date
            } else {
                return standard.value(forKey: kLastTimeSend) as! Date
            }
        }
        set{
            standard.set(newValue, forKey: kLastTimeSend)
        }
    }
    
    public let tokenEndpoint:String = "auth/getToken"
    private let kToken = "DefaultsToken"
    public var token: String {
        get {
            if standard.value(forKey: kToken) == nil {
                return "NilToken"
            } else {
                return standard.value(forKey: kToken) as! String
            }
        }
        set {
            standard.set(newValue, forKey: kToken)
        }
    }
    
    private let kTokenValidDate = "DefaultsTokenValidDate"
    public var tokenExpirationDate: Date {
        get{
            if standard.value(forKey: kTokenValidDate) == nil {
                return Date.init(timeIntervalSince1970: 0)
            } else {
                return standard.value(forKey: kTokenValidDate) as! Date
            }
        }
        set{
            standard.set(newValue, forKey: kTokenValidDate)
        }
    }
    
    private let kSendLogInterval = "DefaultsSendLogInterval"
    public var sendLogInterval: TimeInterval {
        get{
            if standard.value(forKey: kSendLogInterval) == nil {
                return 15 * 60
            } else {
                return standard.value(forKey: kSendLogInterval) as! TimeInterval
            }
        }
        set{
            standard.set(newValue, forKey: kSendLogInterval)
        }
    }
    
    
    private let kAppCredentials = "DefaultsAppCredentials"
    public var appCredentials: String {
        get{
            if standard.value(forKey: kAppCredentials) == nil {
                return "NilCredentials"
            } else {
                return standard.value(forKey: kAppCredentials) as! String
            }
        }
        set{
            standard.set(newValue, forKey: kAppCredentials)
        }
    }
    
    private let kUserEmail = "DefaultsUserEmail"
    public var userEmail: String {
        get{
            if standard.value(forKey: kUserEmail) == nil {
                return "NilUser"
            } else {
                return standard.value(forKey: kUserEmail) as! String
            }
        }
        set{
            standard.set(newValue, forKey: kUserEmail)
        }
    }
    
    /**
     Zmienna ustawień która mówi czy mamy pokazywać logi blue systemu
     */
    private let kShowLogs = "DefaultsShowLogs"
    public var showLogs: Bool {
        get {
            if standard.value(forKey: kShowLogs) == nil {
                return true
            } else {
                return standard.value(forKey: kShowLogs) as! Bool
            }
        }
        set {
            standard.set(newValue, forKey: kShowLogs)
        }
    }
    
    private let kShowNetworkLogs = "DefaultsShowNetworkLogs"
    public var showNetworkLogs: Bool {
        get {
            if standard.value(forKey: kShowNetworkLogs) == nil {
                return false
            } else {
                return standard.value(forKey: kShowNetworkLogs) as! Bool
            }
        }
        set {
            standard.set(newValue, forKey: kShowNetworkLogs)
        }
    }
}
