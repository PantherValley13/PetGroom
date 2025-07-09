//
//  AppDelegate.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import UIKit
import UserNotifications
// import RevenueCat  // DISABLED FOR TESTING

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // DISABLED RevenueCat configuration for testing
        /*
        // Configure RevenueCat
        // TODO: Replace with your actual RevenueCat API key
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .info
        #endif
        
        Purchases.configure(withAPIKey: "appl_YourAPIKey")
        */
        
        // Request notification permissions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            print("Notifications permission granted: \(granted)")
        }
        
        return true
    }
} 
