//
//  AnalyticsView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct AnalyticsDashboardView: View {
    @EnvironmentObject var analyticsManager: AnalyticsManager
    @State private var selectedTimeframe: Timeframe = .week
    @State private var showingBusinessSettings = false
    @State private var showingTaxReport = false
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Timeframe Selector
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Key Metrics Cards
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        MetricCard(
                            title: "Revenue",
                            value: formatCurrency(getRevenue()),
                            unit: selectedTimeframe.rawValue,
                            color: .green
                        )
                        
                        MetricCard(
                            title: "Profit",
                            value: formatCurrency(getProfit()),
                            unit: selectedTimeframe.rawValue,
                            color: .blue
                        )
                        
                        MetricCard(
                            title: "Mileage",
                            value: String(format: "%.1f", getMileage()),
                            unit: "miles",
                            color: .orange
                        )
                        
                        MetricCard(
                            title: "Fuel Cost",
                            value: formatCurrency(getFuelCost()),
                            unit: selectedTimeframe.rawValue,
                            color: .red
                        )
                        
                        MetricCard(
                            title: "Appointments",
                            value: String(getAppointments()),
                            unit: selectedTimeframe.rawValue,
                            color: .purple
                        )
                        
                        MetricCard(
                            title: "Avg/Appointment",
                            value: formatCurrency(getAveragePerAppointment()),
                            unit: "revenue",
                            color: .indigo
                        )
                    }
                    .padding(.horizontal)
                    
                    // Business Tools Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Business Tools")
                                .font(.title2.bold())
                            Spacer()
                            Button("Settings") {
                                showingBusinessSettings = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        // Revenue Projections
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Revenue Projections")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Next \(selectedTimeframe.rawValue)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(formatCurrency(getProjectedRevenue()))
                                        .font(.title2.bold())
                                        .foregroundColor(.green)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Growth")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("+\(getGrowthPercentage(), specifier: "%.1f")%")
                                        .font(.title2.bold())
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Tax Preparation
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tax Preparation")
                                .font(.headline)
                            
                            let taxData = analyticsManager.getTaxDeductionData()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Mileage Deduction")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(formatCurrency(taxData.mileageDeduction))
                                        .font(.title3.bold())
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Fuel Deduction")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(formatCurrency(taxData.fuelDeduction))
                                        .font(.title3.bold())
                                }
                            }
                            
                            Button("View Full Tax Report") {
                                showingTaxReport = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Efficiency Metrics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Efficiency Metrics")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Revenue per Mile")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(formatCurrency(getRevenuePerMile()))
                                        .font(.title3.bold())
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Profit Margin")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(getProfitMargin(), specifier: "%.1f")%")
                                        .font(.title3.bold())
                                        .foregroundColor(getProfitMargin() > 20 ? .green : .orange)
                                }
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // AI Optimization Impact
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Optimization Impact")
                            .font(.title2.bold())
                        
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
                                Text("Saved \(formatCurrency(analyticsManager.getMetric("fuelSaved"))) on fuel")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        analyticsManager.resetMetrics()
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showingBusinessSettings) {
                BusinessSettingsView()
            }
            .sheet(isPresented: $showingTaxReport) {
                TaxReportView()
            }
            .onAppear {
                analyticsManager.loadData()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getRevenue() -> Double {
        switch selectedTimeframe {
        case .week: return analyticsManager.calculateWeeklyRevenue()
        case .month: return analyticsManager.calculateMonthlyRevenue()
        case .year: return analyticsManager.calculateYearlyRevenue()
        }
    }
    
    private func getProfit() -> Double {
        switch selectedTimeframe {
        case .week: return analyticsManager.calculateWeeklyProfit()
        case .month: return analyticsManager.calculateMonthlyProfit()
        case .year: return analyticsManager.calculateYearlyProfit()
        }
    }
    
    private func getMileage() -> Double {
        switch selectedTimeframe {
        case .week: return analyticsManager.calculateWeeklyMileage()
        case .month: return analyticsManager.calculateMonthlyMileage()
        case .year: return analyticsManager.calculateYearlyMileage()
        }
    }
    
    private func getFuelCost() -> Double {
        switch selectedTimeframe {
        case .week: return analyticsManager.calculateWeeklyFuelCost()
        case .month: return analyticsManager.calculateMonthlyFuelCost()
        case .year: return analyticsManager.calculateYearlyFuelCost()
        }
    }
    
    private func getAppointments() -> Int {
        switch selectedTimeframe {
        case .week: return analyticsManager.calculateWeeklyAppointments()
        case .month: return analyticsManager.calculateMonthlyAppointments()
        case .year: return analyticsManager.calculateYearlyAppointments()
        }
    }
    
    private func getAveragePerAppointment() -> Double {
        let appointments = getAppointments()
        return appointments > 0 ? getRevenue() / Double(appointments) : 0
    }
    
    private func getProjectedRevenue() -> Double {
        switch selectedTimeframe {
        case .week: return analyticsManager.projectWeeklyRevenue()
        case .month: return analyticsManager.projectMonthlyRevenue()
        case .year: return analyticsManager.projectYearlyRevenue()
        }
    }
    
    private func getGrowthPercentage() -> Double {
        let current = getRevenue()
        let projected = getProjectedRevenue()
        return current > 0 ? ((projected - current) / current) * 100 : 0
    }
    
    private func getRevenuePerMile() -> Double {
        let mileage = getMileage()
        return mileage > 0 ? getRevenue() / mileage : 0
    }
    
    private func getProfitMargin() -> Double {
        let revenue = getRevenue()
        return revenue > 0 ? (getProfit() / revenue) * 100 : 0
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return String(format: "$%.0f", value)
    }
}

// MARK: - Supporting Views

struct BusinessSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("fuelPricePerGallon") private var fuelPricePerGallon: Double = 3.50
    @AppStorage("milesPerGallon") private var milesPerGallon: Double = 15.0
    @AppStorage("hourlyRate") private var hourlyRate: Double = 75.0
    @AppStorage("overheadCosts") private var overheadCosts: Double = 500.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Fuel Settings") {
                    HStack {
                        Text("Fuel Price per Gallon")
                        Spacer()
                        TextField("Price", value: $fuelPricePerGallon, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Miles per Gallon")
                        Spacer()
                        TextField("MPG", value: $milesPerGallon, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Business Settings") {
                    HStack {
                        Text("Hourly Rate")
                        Spacer()
                        TextField("Rate", value: $hourlyRate, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Monthly Overhead")
                        Spacer()
                        TextField("Overhead", value: $overheadCosts, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Business Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TaxReportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var analyticsManager: AnalyticsManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    let taxData = analyticsManager.getTaxDeductionData()
                    
                    Text("Tax Deduction Report")
                        .font(.title.bold())
                    
                    VStack(alignment: .leading, spacing: 16) {
                        TaxRow(title: "Total Miles Driven", value: String(format: "%.0f", taxData.totalMiles), unit: "miles")
                        TaxRow(title: "Fuel Costs", value: String(format: "$%.2f", taxData.fuelCosts), unit: "")
                        TaxRow(title: "Total Revenue", value: String(format: "$%.2f", taxData.totalRevenue), unit: "")
                        TaxRow(title: "Mileage Deduction", value: String(format: "$%.2f", taxData.mileageDeduction), unit: "")
                        TaxRow(title: "Fuel Deduction", value: String(format: "$%.2f", taxData.fuelDeduction), unit: "")
                        TaxRow(title: "Net Income", value: String(format: "$%.2f", taxData.netIncome), unit: "")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    Text("Note: This report is for informational purposes only. Please consult with a tax professional for official tax preparation.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Tax Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TaxRow: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            VStack(alignment: .trailing) {
                Text(value)
                    .font(.subheadline.bold())
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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

// MARK: - Extensions for AnalyticsManager

// Note: These methods are already defined in AnalyticsManager.swift
// Removing duplicates to avoid compilation errors
