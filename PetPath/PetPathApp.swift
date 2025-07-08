//
//  PetPathApp.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import SwiftUI

@main
struct PetPathApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
        }
    }
}
