//
//  SubscriptionManager.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI
import RevenueCat
import Combine

class SubscriptionManager: ObservableObject {
    @Published var isSubscribed = false
    @Published var isLoading = false
    @Published var currentPackages: [Package] = []
    @Published var customerInfo: CustomerInfo?
    
    init() {
        checkSubscriptionStatus()
    }
    
    func checkSubscriptionStatus() {
        isLoading = true
        
        Purchases.shared.getCustomerInfo { [weak self] info, error in
            DispatchQueue.main.async {
                self?.customerInfo = info
                self?.isSubscribed = info?.entitlements["pro"]?.isActive == true
                self?.isLoading = false
                
                if let error = error {
                    print("Error fetching customer info: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadOfferings() {
        isLoading = true
        
        Purchases.shared.getOfferings { [weak self] offerings, error in
            DispatchQueue.main.async {
                if let packages = offerings?.current?.availablePackages {
                    self?.currentPackages = packages
                }
                self?.isLoading = false
                
                if let error = error {
                    print("Error fetching offerings: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func purchaseSubscription() {
        guard let package = currentPackages.first else {
            loadOfferings()
            return
        }
        
        isLoading = true
        
        Purchases.shared.purchase(package: package) { [weak self] transaction, customerInfo, error, userCancelled in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Purchase failed: \(error.localizedDescription)")
                    return
                }
                
                if userCancelled {
                    print("Purchase cancelled by user")
                    return
                }
                
                self?.checkSubscriptionStatus()
            }
        }
    }
    
    func purchasePackage(_ package: Package) {
        isLoading = true
        
        Purchases.shared.purchase(package: package) { [weak self] transaction, customerInfo, error, userCancelled in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Purchase failed: \(error.localizedDescription)")
                    return
                }
                
                if userCancelled {
                    print("Purchase cancelled by user")
                    return
                }
                
                self?.checkSubscriptionStatus()
            }
        }
    }
    
    func restorePurchases() {
        isLoading = true
        
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Restore failed: \(error.localizedDescription)")
                    return
                }
                
                self?.checkSubscriptionStatus()
            }
        }
    }
} 
