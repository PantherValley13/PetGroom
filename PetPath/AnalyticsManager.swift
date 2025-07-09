//
//  AnalyticsManager.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI
import Combine

class AnalyticsManager: ObservableObject {
    @Published var metrics: [String: Double] = [:]
    
    init() {
        loadData()
    }
    
    func trackMileageSaved(_ miles: Double) {
        metrics["mileageSaved", default: 0] += miles
        saveData()
    }
    
    func trackTimeSaved(_ hours: Double) {
        metrics["timeSaved", default: 0] += hours
        saveData()
    }
    
    func trackFuelSaved(_ dollars: Double) {
        metrics["fuelSaved", default: 0] += dollars
        saveData()
    }
    
    func trackAppointmentCompleted() {
        metrics["appointmentsCompleted", default: 0] += 1
        saveData()
    }
    
    func loadData() {
        if let savedMetrics: [String: Double] = Persistence.shared.load([String: Double].self, for: "analytics") {
            metrics = savedMetrics
        } else {
            // Initialize with sample data for demonstration
            metrics = [
                "mileageSaved": 42.0,
                "timeSaved": 12.5,
                "fuelSaved": 85.0,
                "appointmentsCompleted": 68.0
            ]
            saveData()
        }
    }
    
    private func saveData() {
        Persistence.shared.save(metrics, for: "analytics")
    }
    
    func resetMetrics() {
        metrics.removeAll()
        saveData()
    }
    
    func getMetric(_ key: String) -> Double {
        return metrics[key] ?? 0
    }
} 
