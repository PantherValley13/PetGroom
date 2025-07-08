//
//  SubscriptionView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var manager: SubscriptionManager
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("PetPath Pro")
                .font(.largeTitle.bold())
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "map", title: "AI-Optimized Routes", description: "Reduce mileage by 30%")
                FeatureRow(icon: "note.text", title: "Client Pet Notes", description: "Access critical pet info")
                FeatureRow(icon: "fuelpump", title: "Fuel Savings", description: "Cut fuel costs with efficient routing")
                FeatureRow(icon: "location", title: "Real-Time GPS", description: "Live location tracking and navigation")
            }
            .padding()
            
            VStack(spacing: 16) {
                // Main subscription button
                Button(action: {
                    if manager.isLoading {
                        return
                    }
                    manager.purchaseSubscription()
                }) {
                    HStack {
                        if manager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(manager.isLoading ? "Processing..." : "Start Free Trial - $29/month after")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(manager.isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(manager.isLoading)
                
                // Restore purchases button
                Button(action: {
                    manager.restorePurchases()
                }) {
                    Text("Restore Purchases")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .disabled(manager.isLoading)
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                Text("Cancel anytime. 7-day free trial included.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Link("Terms of Service", destination: URL(string: "https://yourapp.com/terms")!)
                    Text("•")
                        .foregroundColor(.secondary)
                    Link("Privacy Policy", destination: URL(string: "https://yourapp.com/privacy")!)
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .onAppear {
            manager.loadOfferings()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 40)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
