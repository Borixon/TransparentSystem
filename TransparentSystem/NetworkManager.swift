//
//  BSNetworkManager.swift
//  TransparentSystem
//
//  Created by Michał.Krupa on 14/01/2019.
//  Copyright © 2019 Michał.Krupa. All rights reserved.
//

import Moya
import SwiftyJSON
import CoreData

class NetworkManager: NSObject {
    
    // public static let shared:NetworkManager = NetworkManager()
    private let dateFormatter = DateFormatter()
    internal var currentException:Dictionary<String,Any> = ["":""] // TODO: DO zmiany
    
    var moyaPlugins:[PluginType] {
        var array: [PluginType] = []
        if Defaults().showNetworkLogs {
            array.append(NetworkLoggerPlugin(verbose:true))
        }
        return array
    }
    
    
    /*
     Bool sprawdzajacy czy trwa pobieranie tokena
     Troche dziwne rowziazanie, ale neistety nie wiem jak zrobić "po bożemu" barierę, ktora odrzuca rozne watki dobijajace sie do daneej funkcji
     tak aby tylko jeden watek pobieral token a reszta poszla sie "walić"
     */
    var getTokenActive: Bool = false
    var sendActionsActive: Bool = false
    var sendExceptionActive: Bool = false
    var sendExceptionsActive: Bool = false
    var sendTimeActive: Bool = false
    
    public var exceptionIDs: [NSManagedObjectID] = []
    public var actionIDs: [NSManagedObjectID] = []
    open var timeIDs: [NSManagedObjectID] = []
    
    override init() {
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
    }
    
    // Czy tokien jest ważny
    var isTokenValid: Bool {
        if Defaults().tokenExpirationDate < Date() {
            return false
        }
        return true
    }
    
    // Zmienna do generowania czasu w unix standardzie
    var unixTime: String {
        return String(Int(Date().timeIntervalSince1970))
    }
    
    internal func sendException(exc: Dictionary<String,Any>, completion: @escaping (_ success:Bool) -> ()) {
        
        guard !sendExceptionActive else { return }
        sendExceptionActive = true
        guard Reachability().isConnected else {
            return }
        let provider = MoyaProvider<LogAPI>(plugins: moyaPlugins)
        provider.request(.exception(exc:exc)) { result in
            
            self.sendExceptionActive = false
            
            switch result {
            case let .success(moyaResponse):
                if 200...202 ~= moyaResponse.statusCode {
                    completion(true)
                } else {
                    completion(false)
                }
            case let .failure(error):
                Logger.print("Blue System internal error sending exception: \(error)")
                completion(false)
            }
        }
    }
    
    internal func sendExceptions(with objectIDs: [NSManagedObjectID], completion: @escaping (_ success:Bool) -> ()) {
        
        guard !sendExceptionsActive else { return }
        sendExceptionsActive = true
        guard Reachability().isConnected else {
            return }
        
        let provider = MoyaProvider<LogAPI>(plugins: moyaPlugins)
        provider.request(.exceptions(ids: objectIDs)) { result in
            
            
            
            switch result {
            case let .success(moyaResponse):
                if 200...202 ~= moyaResponse.statusCode {
                    completion(true)
                } else {
                    completion(false)
                }
            case let .failure(error):
                Logger.print("Blue System internal error sending exceptions: \(error)")
                completion(false)
            }
            self.sendExceptionsActive = false
        }
    }
    
    internal func sendTime(with objectIDs: [NSManagedObjectID], completion: @escaping (_ success:Bool) -> ()) {
        
        guard !sendTimeActive else { return }
        sendTimeActive = true
        guard Reachability().isConnected else {
            return }
        MoyaProvider<LogAPI>(plugins: moyaPlugins).request(.time(ids: objectIDs), completion: { result in
            
            
            
            switch result {
            case let .success(moyaResponse):
                if 200...202 ~= moyaResponse.statusCode {
                    completion(true)
                } else {
                    completion(false)
                }
            case let .failure(error):
                Logger.print("Blue System internal error sending time: \(error)")
                completion(false)
            }
            self.sendTimeActive = false
        })
    }
    
    internal func sendActions(with objectIDs: [NSManagedObjectID], completion: @escaping (_ success:Bool) -> ()) {
        
        guard !sendActionsActive else { return }
        sendActionsActive = true
        guard Reachability().isConnected else {
            return }
        MoyaProvider<LogAPI>(plugins: moyaPlugins).request(.action(ids: objectIDs), completion: { result in
            
            
            
            switch result {
            case let .success(moyaResponse):
                if 200...202 ~= moyaResponse.statusCode {
                    self.handleResponse(withToken:moyaResponse.data)
                    completion(true)
                } else {
                    completion(false)
                }
            case let .failure(error):
                Logger.print("Blue System internal error sending actions: \(error)")
                completion(false)
            }
            self.sendActionsActive = false
        })
    }
    
    internal func getToken(completion: @escaping (_ success:Bool) -> ()) {
        
        guard !getTokenActive else { return }
        getTokenActive = true
        guard Reachability().isConnected else {
            return }
        MoyaProvider<LogAPI>(plugins: moyaPlugins).request(.token, completion: { result in
            
            self.getTokenActive = false
            
            switch result {
            case let .success(moyaResponse):
                Logger.print("Blue System received new token")
                if 200...202 ~= moyaResponse.statusCode {
                    self.handleResponse(withToken:moyaResponse.data)
                    completion(true)
                }
                break
            case let .failure(error):
                LogManager.shared.createExceptionLog(FailGetTokenLogException(message: "Error: \(error)"))
                Logger.print("Error getting response with Blue System token \(error)")
                completion(false)
                break
            }
        })
        
    }
    
    private func handleResponse(withToken tokenResponse:Data) {
        do {
            let json = try JSON(data: tokenResponse)
            if let token = json["data"]["token"]["hash"].string {
                Defaults().token = token
            }
            if let date = dateFormatter.date(from: json["data"]["token"]["expirationDate"].stringValue) {
                Defaults().tokenExpirationDate = date
            }
        } catch{
            LogManager.shared.createExceptionLog(JSONParsingLogException(message: "Token response handler"))
            Logger.print("Blue System internal error parsing JSON")
        }
    }
    
}

enum LogAPI {
    case time(ids:[NSManagedObjectID])
    case action(ids:[NSManagedObjectID])
    case exceptions(ids:[NSManagedObjectID])    // Wysyłanie wielu Exceptionów, dane z Core Data
    case exception(exc:Dictionary<String,Any>)  // Wysyłania pojedynczego Exceptiona, dane pobierane z LogManagera currentException
    case token
}

extension LogAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: Defaults().baseURL + "/api/v" + Defaults().apiVersion)!
    }
    
    var path: String {
        switch self {
        case .time:
            return Defaults().timeEndopoint
        case .action:
            return Defaults().actionEndopoint
        case .exception, .exceptions:
            return Defaults().exceptionEndpoint
        case .token:
            return Defaults().tokenEndpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .exception, .exceptions, .action, .time:
            return .post
        case .token:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .time(let ids):
            return Task.requestParameters(parameters: LogManager.shared.getTimeBody(with: ids), encoding: JSONEncoding.default)
        case .action(let ids):
            return Task.requestParameters(parameters: LogManager.shared.getActionBody(with: ids), encoding: JSONEncoding.default)
        case .exceptions(let ids):
            return Task.requestParameters(parameters: LogManager.shared.getExceptionBody(with: ids), encoding: JSONEncoding.default)
        case .exception(let exc):
            return Task.requestParameters(parameters: exc, encoding: JSONEncoding.default)
        case .token:
            return Task.requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .time:
            return ["Authorization":"Bearer " + Defaults().token]
        case .action:
            return ["Authorization":"Bearer " + Defaults().token]
        case .exception, .exceptions:
            return ["Authorization":"Bearer " + Defaults().token]
        case .token:
            let credentials = String(Defaults().appCredentials+":"+NetworkManager().unixTime).data(using: .utf8)
            if let base64encoded = credentials?.base64EncodedString() {
                return ["Authorization":"Basic " + base64encoded]
            } else {
                return nil
            }
        }
    }
    
}

