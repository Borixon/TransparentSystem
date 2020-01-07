//
//  AppDelegate.swift
//  ExcampleApp
//
//  Created by Michał Krupa on 06/01/2020.
//  Copyright © 2020 Michał Krupa. All rights reserved.
//

import UIKit
import TransparentSystem

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let options = launchOptions {
            TransparentSystem.shared.log(DidFinishLaunchingWith(options: options))
        }
        return true
    }

}

struct DidFinishLaunchingWith: ActionLogProtocol {
    init(group: String, type: String, name: String, value: String, timeStamp: Date) {
        self.value = value
    }
        
    init(options: [UIApplication.LaunchOptionsKey: Any]) {
        var optionsToValue: String = ""
        
        for key in options.keys {
            let value = options[key].coreStoreDumpString
            optionsToValue.append(contentsOf: "[\(key):\(value)] ")
        }
        
        self.value = optionsToValue
    }
    var group: String   = "AppDelegate"
    var type: String    = "didFinishLaunching"
    var name: String    = "options"
    var value: String
    var timeStamp: Date = Date()
}

