//
//  SubscriptionManager.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

class SubscriptionManager: ObservableObject {
    @Published var isSubscribed = false
    
    func purchaseSubscription() {
        // TODO: Add RevenueCat integration later
        isSubscribed = true
    }
} 