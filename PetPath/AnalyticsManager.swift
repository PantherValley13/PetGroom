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
    @Published var dailyMileage: [Date: Double] = [:]
    @Published var fuelCosts: [Date: Double] = [:]
    @Published var revenue: [Date: Double] = [:]
    @Published var appointments: [Date: Int] = [:]
    
    @Published var clientValues: [UUID: Double] = [:] // clientId -> CLV
    @Published var whatIfPriceAdjustments: [Double] = [] // what-if scenario values
    @Published var benchmarkingData: [String: Double] = [:] // peer group metrics
    
    // Additional properties for dashboard
    @Published var newClientsCount: Int = 0
    @Published var churnRate: Double = 0.0
    @Published var clientReviews: [ClientReview] = []
    
    // Business settings
    @AppStorage("fuelPricePerGallon") private var fuelPricePerGallon: Double = 3.50
    @AppStorage("milesPerGallon") private var milesPerGallon: Double = 15.0
    @AppStorage("hourlyRate") private var hourlyRate: Double = 75.0
    @AppStorage("overheadCosts") private var overheadCosts: Double = 500.0 // monthly
    
    init() {
        loadData()
    }
    
    // MARK: - Basic Metrics
    
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
    
    // MARK: - Enhanced Business Tools
    
    func trackDailyMileage(_ miles: Double, for date: Date = Date()) {
        let dayKey = Calendar.current.startOfDay(for: date)
        dailyMileage[dayKey, default: 0] += miles
        saveData()
    }
    
    func trackFuelCost(_ cost: Double, for date: Date = Date()) {
        let dayKey = Calendar.current.startOfDay(for: date)
        fuelCosts[dayKey, default: 0] += cost
        saveData()
    }
    
    func trackRevenue(_ amount: Double, for date: Date = Date(), client: Client? = nil) {
        let dayKey = Calendar.current.startOfDay(for: date)
        revenue[dayKey, default: 0] += amount
        saveData()
        
        if let client = client {
            let clv = calculateCLV(for: client)
            clientValues[client.id] = clv
        }
    }
    
    func trackAppointment(_ date: Date = Date(), client: Client? = nil) {
        let dayKey = Calendar.current.startOfDay(for: date)
        appointments[dayKey, default: 0] += 1
        saveData()
        
        if let client = client {
            let clv = calculateCLV(for: client)
            clientValues[client.id] = clv
        }
    }
    
    // MARK: - Calculations
    
    func calculateFuelCost(for miles: Double) -> Double {
        return (miles / milesPerGallon) * fuelPricePerGallon
    }
    
    func calculateDailyFuelCost(for date: Date = Date()) -> Double {
        let dayKey = Calendar.current.startOfDay(for: date)
        let miles = dailyMileage[dayKey] ?? 0
        return calculateFuelCost(for: miles)
    }
    
    func calculateWeeklyRevenue() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return revenue.filter { date, _ in
            date >= weekStart
        }.values.reduce(0, +)
    }
    
    func calculateMonthlyRevenue() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return revenue.filter { date, _ in
            date >= monthStart
        }.values.reduce(0, +)
    }
    
    func calculateWeeklyProfit() -> Double {
        let weeklyRevenue = calculateWeeklyRevenue()
        let weeklyFuelCost = calculateWeeklyFuelCost()
        let weeklyOverhead = overheadCosts / 4.33 // Approximate weeks per month
        return weeklyRevenue - weeklyFuelCost - weeklyOverhead
    }
    
    func calculateMonthlyProfit() -> Double {
        let monthlyRevenue = calculateMonthlyRevenue()
        let monthlyFuelCost = calculateMonthlyFuelCost()
        return monthlyRevenue - monthlyFuelCost - overheadCosts
    }
    
    func calculateWeeklyFuelCost() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return fuelCosts.filter { date, _ in
            date >= weekStart
        }.values.reduce(0, +)
    }
    
    func calculateMonthlyFuelCost() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return fuelCosts.filter { date, _ in
            date >= monthStart
        }.values.reduce(0, +)
    }
    
    func calculateWeeklyMileage() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return dailyMileage.filter { date, _ in
            date >= weekStart
        }.values.reduce(0, +)
    }
    
    func calculateMonthlyMileage() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return dailyMileage.filter { date, _ in
            date >= monthStart
        }.values.reduce(0, +)
    }
    
    func calculateWeeklyAppointments() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return appointments.filter { date, _ in
            date >= weekStart
        }.values.reduce(0, +)
    }
    
    func calculateMonthlyAppointments() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return appointments.filter { date, _ in
            date >= monthStart
        }.values.reduce(0, +)
    }
    
    // MARK: - Revenue Projections
    
    func projectWeeklyRevenue() -> Double {
        let currentWeeklyRevenue = calculateWeeklyRevenue()
        let currentWeeklyAppointments = calculateWeeklyAppointments()
        
        // Project based on current performance
        if currentWeeklyAppointments > 0 {
            let averageRevenuePerAppointment = currentWeeklyRevenue / Double(currentWeeklyAppointments)
            let projectedAppointments = Double(currentWeeklyAppointments) * 1.1 // 10% growth
            return averageRevenuePerAppointment * projectedAppointments
        }
        
        return currentWeeklyRevenue
    }
    
    func projectMonthlyRevenue() -> Double {
        let currentMonthlyRevenue = calculateMonthlyRevenue()
        let currentMonthlyAppointments = calculateMonthlyAppointments()
        
        // Project based on current performance
        if currentMonthlyAppointments > 0 {
            let averageRevenuePerAppointment = currentMonthlyRevenue / Double(currentMonthlyAppointments)
            let projectedAppointments = Double(currentMonthlyAppointments) * 1.15 // 15% growth
            return averageRevenuePerAppointment * projectedAppointments
        }
        
        return currentMonthlyRevenue
    }
    
    // MARK: - Tax Preparation
    
    func getTaxDeductionData() -> TaxDeductionData {
        let yearlyMileage = calculateYearlyMileage()
        let yearlyFuelCost = calculateYearlyFuelCost()
        let yearlyRevenue = calculateYearlyRevenue()
        
        return TaxDeductionData(
            totalMiles: yearlyMileage,
            fuelCosts: yearlyFuelCost,
            totalRevenue: yearlyRevenue,
            mileageDeduction: yearlyMileage * 0.655, // 2024 IRS rate
            fuelDeduction: yearlyFuelCost,
            netIncome: yearlyRevenue - yearlyFuelCost - (overheadCosts * 12)
        )
    }
    
    // MARK: - Yearly Calculations
    
    func calculateYearlyRevenue() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let yearStart = calendar.dateInterval(of: .year, for: now)?.start ?? now
        
        return revenue.filter { date, _ in
            date >= yearStart
        }.values.reduce(0, +)
    }
    
    func calculateYearlyProfit() -> Double {
        let yearlyRevenue = calculateYearlyRevenue()
        let yearlyFuelCost = calculateYearlyFuelCost()
        return yearlyRevenue - yearlyFuelCost - (overheadCosts * 12)
    }
    
    func calculateYearlyMileage() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let yearStart = calendar.dateInterval(of: .year, for: now)?.start ?? now
        
        return dailyMileage.filter { date, _ in
            date >= yearStart
        }.values.reduce(0, +)
    }
    
    func calculateYearlyFuelCost() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let yearStart = calendar.dateInterval(of: .year, for: now)?.start ?? now
        
        return fuelCosts.filter { date, _ in
            date >= yearStart
        }.values.reduce(0, +)
    }
    
    func calculateYearlyAppointments() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let yearStart = calendar.dateInterval(of: .year, for: now)?.start ?? now
        
        return appointments.filter { date, _ in
            date >= yearStart
        }.values.reduce(0, +)
    }
    
    func projectYearlyRevenue() -> Double {
        let currentYearlyRevenue = calculateYearlyRevenue()
        let currentYearlyAppointments = calculateYearlyAppointments()
        
        if currentYearlyAppointments > 0 {
            let averageRevenuePerAppointment = currentYearlyRevenue / Double(currentYearlyAppointments)
            let projectedAppointments = Double(currentYearlyAppointments) * 1.2 // 20% growth
            return averageRevenuePerAppointment * projectedAppointments
        }
        
        return currentYearlyRevenue
    }
    
    // MARK: - New Methods for Added Features
    
    func calculateCLV(for client: Client) -> Double {
        // Simple, sample calculation: total spent
        return client.totalSpent
    }
    
    func simulateWhatIfPriceAdjustment(_ percent: Double) -> WhatIfResult {
        let currentRevenue = calculateMonthlyRevenue()
        let projectedRevenue = currentRevenue * (1 + percent)
        let estimatedChurn = abs(percent) * 0.5 // simple model: 50% churn for 100% price increase
        return WhatIfResult(projectedMonthlyRevenue: projectedRevenue, estimatedChurn: estimatedChurn)
    }
    
    func updateBenchmarkingData(_ data: [String: Double]) {
        benchmarkingData = data
    }
    
    var benchmarkingDataModel: BenchmarkingData? {
        if benchmarkingData.isEmpty {
            return nil
        }
        return BenchmarkingData(metrics: benchmarkingData)
    }
    
    func analyzeReviewSentiment(_ text: String) -> Double {
        // Simple logic: negative words reduce score, positive words increase
        let lowercased = text.lowercased()
        let negatives = ["bad", "terrible", "late", "upset", "angry"]
        let positives = ["great", "excellent", "friendly", "happy", "love"]
        var score = 0.0
        for word in negatives { if lowercased.contains(word) { score -= 0.3 } }
        for word in positives { if lowercased.contains(word) { score += 0.3 } }
        return max(-1.0, min(1.0, score))
    }
    
    // MARK: - Data Management
    
    func loadData() {
        if let savedMetrics: [String: Double] = Persistence.shared.load([String: Double].self, for: "analytics") {
            metrics = savedMetrics
        }
        
        if let savedDailyMileage: [Date: Double] = Persistence.shared.load([Date: Double].self, for: "dailyMileage") {
            dailyMileage = savedDailyMileage
        }
        
        if let savedFuelCosts: [Date: Double] = Persistence.shared.load([Date: Double].self, for: "fuelCosts") {
            fuelCosts = savedFuelCosts
        }
        
        if let savedRevenue: [Date: Double] = Persistence.shared.load([Date: Double].self, for: "revenue") {
            revenue = savedRevenue
        }
        
        if let savedAppointments: [Date: Int] = Persistence.shared.load([Date: Int].self, for: "appointments") {
            appointments = savedAppointments
        }
        
        if let savedClientValues: [UUID: Double] = Persistence.shared.load([UUID: Double].self, for: "clientValues") {
            clientValues = savedClientValues
        }
        
        if let savedWhatIfPriceAdjustments: [Double] = Persistence.shared.load([Double].self, for: "whatIfPriceAdjustments") {
            whatIfPriceAdjustments = savedWhatIfPriceAdjustments
        }
        
        if let savedBenchmarkingData: [String: Double] = Persistence.shared.load([String: Double].self, for: "benchmarkingData") {
            benchmarkingData = savedBenchmarkingData
        }
        
        // Initialize with sample data if empty
        if metrics.isEmpty {
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
        Persistence.shared.save(dailyMileage, for: "dailyMileage")
        Persistence.shared.save(fuelCosts, for: "fuelCosts")
        Persistence.shared.save(revenue, for: "revenue")
        Persistence.shared.save(appointments, for: "appointments")
        Persistence.shared.save(clientValues, for: "clientValues")
        Persistence.shared.save(whatIfPriceAdjustments, for: "whatIfPriceAdjustments")
        Persistence.shared.save(benchmarkingData, for: "benchmarkingData")
    }
    
    func resetMetrics() {
        metrics.removeAll()
        dailyMileage.removeAll()
        fuelCosts.removeAll()
        revenue.removeAll()
        appointments.removeAll()
        clientValues.removeAll()
        whatIfPriceAdjustments.removeAll()
        benchmarkingData.removeAll()
        saveData()
    }
    
    func getMetric(_ key: String) -> Double {
        return metrics[key] ?? 0
    }
}

// MARK: - Supporting Structures

struct ClientReview {
    let clientId: UUID
    let rating: Int
    let comment: String
    let sentiment: Double
    let date: Date
}

struct WhatIfResult {
    let projectedMonthlyRevenue: Double
    let estimatedChurn: Double
}

struct BenchmarkingData {
    let metrics: [String: Double]
}

struct TaxDeductionData {
    let totalMiles: Double
    let fuelCosts: Double
    let totalRevenue: Double
    let mileageDeduction: Double
    let fuelDeduction: Double
    let netIncome: Double
} 

