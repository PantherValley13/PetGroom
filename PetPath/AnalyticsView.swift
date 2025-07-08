//
//  AnalyticsView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var analyticsManager: AnalyticsManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    MetricCard(
                        title: "Miles Saved",
                        value: String(format: "%.1f", analyticsManager.getMetric("mileageSaved")),
                        unit: "miles",
                        color: .green
                    )
                    
                    MetricCard(
                        title: "Time Saved",
                        value: String(format: "%.1f", analyticsManager.getMetric("timeSaved")),
                        unit: "hours",
                        color: .blue
                    )
                }
                
                HStack {
                    MetricCard(
                        title: "Fuel Saved",
                        value: "$" + String(format: "%.0f", analyticsManager.getMetric("fuelSaved")),
                        unit: "this month",
                        color: .orange
                    )
                    
                    MetricCard(
                        title: "Appointments",
                        value: String(format: "%.0f", analyticsManager.getMetric("appointmentsCompleted")),
                        unit: "completed",
                        color: .purple
                    )
                }
                
                // Weekly summary card
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Week's Impact")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(.green)
                            Text("Reduced driving by \(String(format: "%.1f", analyticsManager.getMetric("mileageSaved"))) miles")
                        }
                        
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("Saved \(String(format: "%.1f", analyticsManager.getMetric("timeSaved"))) hours")
                        }
                        
                        HStack {
                            Image(systemName: "fuelpump.fill")
                                .foregroundColor(.orange)
                            Text("Saved $\(String(format: "%.0f", analyticsManager.getMetric("fuelSaved"))) on fuel")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        analyticsManager.resetMetrics()
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                analyticsManager.loadData()
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title.bold())
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}
