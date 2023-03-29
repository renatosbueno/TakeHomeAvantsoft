//
//  AppDelegate.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 29/03/23.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        
        window?.rootViewController = HomeModuleConfigurator().createModule()
        window?.makeKeyAndVisible()
        
        return true
    }
}

