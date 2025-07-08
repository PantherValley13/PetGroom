//
//  SubscriptionView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct SubscriptionView: View {
    @Binding var isSubscribed: Bool
    
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
            }
            .padding()
            
            Button(action: {
                isSubscribed = true
            }) {
                Text("Start Free Trial - $29/month after")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Text("Cancel anytime. 7-day free trial included.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
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
