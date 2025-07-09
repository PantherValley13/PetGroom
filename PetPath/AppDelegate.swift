//
//  AppDelegate.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import UIKit
import RevenueCat

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure RevenueCat
        // TODO: Replace with your actual RevenueCat API key
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .info
        #endif
        
        Purchases.configure(withAPIKey: "appl_YourAPIKey")
        
        return true
    }
} 