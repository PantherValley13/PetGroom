import SwiftUI

struct DashboardView: View {
    @ObservedObject var analyticsManager: AnalyticsManager
    @State private var priceAdjustment: Double = 0.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Key Metrics Cards
                HStack(spacing: 16) {
                    MetricCard(title: "New Clients", value: "\(analyticsManager.newClientsCount)", unit: "", color: .blue)
                    MetricCard(title: "Churn Rate", value: String(format: "%.1f%%", analyticsManager.churnRate * 100), unit: "", color: .red)
                    MetricCard(title: "Top Streak", value: "\(GamificationService.shared.topStreak)", unit: "", color: .green)
                    MetricCard(title: "Top Referrer", value: GamificationService.shared.topReferrerName, unit: "", color: .purple)
                }
                .padding(.horizontal)
                
                // Warning for dissatisfied clients (reviewSentiment < 0)
                if analyticsManager.clientReviews.compactMap({ $0.sentiment }).contains(where: { $0 < 0 }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text("Warning: Possible dissatisfied clients detected")
                            .foregroundColor(.yellow)
                            .bold()
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // Metrics Section - Show CLV for each client if available
                VStack(alignment: .leading, spacing: 8) {
                    Text("Client Lifetime Value (CLV)")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(Array(analyticsManager.clientValues.keys), id: \.self) { clientId in
                        HStack {
                            Text(clientId.uuidString.prefix(8))
                            Spacer()
                            Text("$\(String(format: "%.2f", analyticsManager.clientValues[clientId] ?? 0))")
                                .bold()
                        }
                        .padding(.horizontal)
                    }
                }
                
                // What-If Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("What-If: Price Adjustment")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Slider(value: $priceAdjustment, in: -0.2...0.2, step: 0.01)
                        .padding(.horizontal)
                    
                    let simulation = analyticsManager.simulateWhatIfPriceAdjustment(priceAdjustment)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Projected Monthly Revenue")
                                .font(.subheadline)
                            Text("$\(String(format: "%.2f", simulation.projectedMonthlyRevenue))")
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Estimated Churn")
                                .font(.subheadline)
                            Text(String(format: "%.1f%%", simulation.estimatedChurn * 100))
                                .bold()
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Benchmarking Section
                if let benchmarking = analyticsManager.benchmarkingDataModel {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Benchmarking")
                            .font(.headline)
                            .padding(.horizontal)
                        ForEach(benchmarking.metrics.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack {
                                Text(key)
                                Spacer()
                                Text(String(format: "%.2f", value))
                                    .bold()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .overlay(
            // Sync Status Banner at bottom
            VStack {
                Spacer()
                HStack {
                    Image(systemName: OfflineSyncService.shared.isOnline ? "checkmark.circle.fill" : "wifi.slash")
                        .foregroundColor(OfflineSyncService.shared.isOnline ? .green : .red)
                    Text("Last Sync: \(OfflineSyncService.shared.lastSync?.formatted(date: .numeric, time: .shortened) ?? "Never")")
                    Spacer()
                    Text("Pending Changes: \(OfflineSyncService.shared.pendingChanges.count)")
                }
                .font(.footnote)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(radius: 2)
            }
        )
    }
}

// Supporting Views and Models
// Note: MetricCard is already defined in AnalyticsView.swift
