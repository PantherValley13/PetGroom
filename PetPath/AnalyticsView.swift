//
//  AnalyticsView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    MetricCard(title: "Miles Saved", value: "42", unit: "this month")
                    MetricCard(title: "Time Saved", value: "12h", unit: "this month")
                }
                
                HStack {
                    MetricCard(title: "Fuel Saved", value: "$85", unit: "this month")
                    MetricCard(title: "Appointments", value: "68", unit: "this month")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Analytics")
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title.bold())
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
