//
//  RouteView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI
import CoreLocation

struct RouteView: View {
    @EnvironmentObject var clientManager: ClientManager
    @EnvironmentObject var analyticsManager: AnalyticsManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var routeManager: RouteManager?
    @State private var showingAddAppointment = false
    @State private var showingAIFeatures = false
    @StateObject private var realTimeRouteService = RealTimeRouteService.shared
    
    @State private var showingLiveConditionAlert = false
    @State private var showingRescheduleSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Map or Permission View
                if locationManager.authorizationStatus == .authorizedWhenInUse ||
                   locationManager.authorizationStatus == .authorizedAlways {
                    
                    if let routeManager = routeManager {
                        MapView(
                            userLocation: locationManager.userLocation,
                            appointments: routeManager.optimizedRoute
                        )
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        ZStack {
                            Color.gray.opacity(0.2)
                            ProgressView("Loading...")
                        }
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                } else {
                    LocationPermissionView()
                        .frame(height: 300)
                        .padding(.horizontal)
                        .environmentObject(locationManager)
                }
                
                // Conditional Banners
                if let routeManager = routeManager {
                    if routeManager.isBurstDay {
                        Text("High-demand day detected! Consider splitting routes or prepping early.")
                            .font(.callout)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    if routeManager.routeDelays.values.contains(where: { $0 > 0 }) {
                        Text("AI added extra time for some pets due to behavior needs.")
                            .font(.callout)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }
                
                // AI Optimization Controls
                if let routeManager = routeManager {
                    VStack(spacing: 12) {
                        HStack {
                            Button("AI Optimize Route", action: {
                                routeManager.optimizeRoute()
                            })
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                            
                            Button("AI Features") {
                                showingAIFeatures = true
                            }
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        if routeManager.isOptimizing {
                            VStack {
                                ProgressView("AI Optimizing Route...")
                                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                Text("\(Int(routeManager.optimizationProgress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Appointments List
                if let routeManager = routeManager {
                    List {
                        Section("Today's Appointments") {
                            let todaysAppointments = routeManager.getTodaysAppointments()
                            if todaysAppointments.isEmpty {
                                Text("No appointments today")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                ForEach(todaysAppointments) { appointment in
                                    AppointmentRow(appointment: appointment, delayMinutes: Int(routeManager.routeDelays[appointment.id] ?? 0))
                                        .swipeActions {
                                            Button("Complete") {
                                                routeManager.completeAppointment(appointment)
                                            }
                                            .tint(.green)
                                        }
                                }
                            }
                        }
                        
                        Section("All Appointments") {
                            if routeManager.appointments.isEmpty {
                                Text("No appointments scheduled")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                ForEach(routeManager.appointments) { appointment in
                                    AppointmentRow(appointment: appointment, delayMinutes: Int(routeManager.routeDelays[appointment.id] ?? 0))
                                        .swipeActions {
                                            Button("Delete") {
                                                routeManager.deleteAppointment(appointment)
                                            }
                                            .tint(.red)
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                
                // Simulate running late button
                Button("Simulate Running Late") {
                    showingRescheduleSheet = true
                }
                .padding()
            }
            .navigationTitle("Route")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        if let routeManager = routeManager,
                           routeManager.liveTraffic.values.contains(where: { $0 == .heavy }) ||
                               routeManager.liveWeather.values.contains(where: { $0 == .rainy || $0 == .snowy }) {
                            Button {
                                showingLiveConditionAlert = true
                            } label: {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                            }
                            .alert("Live conditions detected! Some appointments may be delayed.", isPresented: $showingLiveConditionAlert) {
                                Button("OK", role: .cancel) { }
                            }
                        }
                        
                        Button(action: { showingAddAppointment = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddAppointment) {
                if let routeManager = routeManager {
                    AddAppointmentView(routeManager: routeManager)
                        .environmentObject(clientManager)
                }
            }
            .sheet(isPresented: $showingAIFeatures) {
                AIFeaturesView()
                    .environmentObject(clientManager)
            }
            .sheet(isPresented: $showingRescheduleSheet) {
                if let routeManager = routeManager, let firstAppointment = routeManager.appointments.first {
                    let suggestions = realTimeRouteService.suggestRescheduleOptions(for: firstAppointment, appointments: routeManager.appointments)
                    RescheduleSuggestionsView(suggestions: suggestions.map { RescheduleSuggestion(description: $0) })
                }
            }
        }
        .onAppear {
            if routeManager == nil {
                routeManager = RouteManager(analyticsManager: analyticsManager)
            }
        }
    }
}

struct AppointmentRow: View {
    let appointment: Appointment
    let delayMinutes: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.client.name)
                    .font(.headline)
                Text(appointment.pet.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(appointment.serviceType.rawValue)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(appointment.time, style: .time)
                    .font(.subheadline)
                Text("\(appointment.duration) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if delayMinutes > 0 {
                Text("+\(delayMinutes)m buffer")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
                    .padding(.leading, 6)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Supporting Models

struct RescheduleSuggestion: Identifiable {
    let id = UUID()
    let description: String
    let newTime: Date?
    let reason: String?
    
    init(description: String, newTime: Date? = nil, reason: String? = nil) {
        self.description = description
        self.newTime = newTime
        self.reason = reason
    }
}

// Assuming RescheduleSuggestionsView exists and takes suggestions: [RescheduleSuggestion]
struct RescheduleSuggestionsView: View {
    let suggestions: [RescheduleSuggestion]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(suggestions) { suggestion in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(suggestion.description)
                            .font(.headline)
                        if let newTime = suggestion.newTime {
                            Text("New Time: \(newTime, style: .time)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        if let reason = suggestion.reason {
                            Text("Reason: \(reason)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Reschedule Suggestions")
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

struct AIFeaturesView: View {
    @EnvironmentObject var clientManager: ClientManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedClient: Client?
    @State private var selectedPet: Pet?
    @State private var aiSuggestions: [String] = []
    @State private var isLoading = false
    @State private var showingTestResults = false
    @State private var testResults: [String: Bool] = [:]
    
    private let aiService = AIService()
    
    var body: some View {
        NavigationView {
            List {
                Section("AI Route Optimization") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Smart Route Planning")
                            .font(.headline)
                        Text("AI analyzes traffic patterns, distances, and appointment durations to create the most efficient route.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Test Route Optimization") {
                            testRouteOptimization()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                
                Section("Pet Behavior Analysis") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Predictive Pet Care")
                            .font(.headline)
                        Text("AI analyzes pet behavior patterns to suggest optimal appointment times and service durations.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let pet = selectedPet {
                            Button("Analyze \(pet.name)") {
                                analyzePet(pet)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                }
                
                Section("Client Preferences") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personalized Scheduling")
                            .font(.headline)
                        Text("AI learns client preferences and suggests appointment times that work best for each client.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let client = selectedClient {
                            Button("Analyze \(client.name)") {
                                analyzeClient(client)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                }
                
                Section("Client & Pet Selection") {
                    Picker("Client", selection: $selectedClient) {
                        Text("Select Client").tag(nil as Client?)
                        ForEach(clientManager.clients, id: \.id) { client in
                            Text(client.name).tag(client as Client?)
                        }
                    }
                    .onChange(of: selectedClient) { _, _ in
                        selectedPet = nil
                    }
                    
                    if let client = selectedClient {
                        Picker("Pet", selection: $selectedPet) {
                            Text("Select Pet").tag(nil as Pet?)
                            ForEach(clientManager.pets.filter { $0.ownerId == client.id }, id: \.id) { pet in
                                Text(pet.name).tag(pet as Pet?)
                            }
                        }
                    }
                }
                
                if !aiSuggestions.isEmpty {
                    Section("AI Analysis Results") {
                        ForEach(aiSuggestions, id: \.self) { suggestion in
                            Text(suggestion)
                                .font(.caption)
                                .padding(.vertical, 4)
                        }
                    }
                }
                
                if isLoading {
                    Section {
                        HStack {
                            ProgressView()
                            Text("AI is analyzing...")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button("Run All AI Tests") {
                        runAllTests()
                    }
                    .disabled(isLoading)
                    
                    Button("Show Test Results") {
                        showingTestResults = true
                    }
                    .disabled(testResults.isEmpty)
                }
            }
            .navigationTitle("AI Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingTestResults) {
                AIFeaturesTestView()
            }
        }
    }
    
    private func testRouteOptimization() {
        isLoading = true
        aiSuggestions.removeAll()
        
        let testAppointments = [
            Appointment(
                client: Client(name: "Test Client 1", address: "123 Main St", phone: "555-1234"),
                pet: Pet(name: "Max", breed: "Golden Retriever", notes: "Friendly dog", temperament: "Calm", ownerId: UUID()),
                time: Date().addingTimeInterval(3600),
                duration: 60,
                serviceType: .grooming
            ),
            Appointment(
                client: Client(name: "Test Client 2", address: "456 Oak Ave", phone: "555-5678"),
                pet: Pet(name: "Bella", breed: "Persian Cat", notes: "Loves being brushed", temperament: "Friendly", ownerId: UUID()),
                time: Date().addingTimeInterval(7200),
                duration: 45,
                serviceType: .bath
            ),
            Appointment(
                client: Client(name: "Test Client 3", address: "789 Pine Rd", phone: "555-9012"),
                pet: Pet(name: "Charlie", breed: "Labrador", notes: "Needs extra attention", temperament: "Energetic", ownerId: UUID()),
                time: Date().addingTimeInterval(10800),
                duration: 30,
                serviceType: .nailTrim
            )
        ]
        
        aiService.optimizeRoute(appointments: testAppointments) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let optimizedAppointments):
                    aiSuggestions.append("✅ Route optimization successful!")
                    aiSuggestions.append("Original route: \(testAppointments.count) appointments")
                    aiSuggestions.append("Optimized route: \(optimizedAppointments.count) appointments")
                    aiSuggestions.append("AI considered: time, distance, service duration, and traffic patterns")
                case .failure(let error):
                    aiSuggestions.append("❌ Route optimization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func analyzePet(_ pet: Pet) {
        isLoading = true
        aiSuggestions.removeAll()
        
        Task {
            let summary = await aiService.generatePetSummary(pet: pet)
            let duration = await aiService.predictAppointmentDuration(for: pet, serviceType: .grooming)
            
            await MainActor.run {
                isLoading = false
                aiSuggestions.append("🐾 Pet Analysis for \(pet.name)")
                aiSuggestions.append("Breed: \(pet.breed)")
                aiSuggestions.append("Temperament: \(pet.temperament)")
                aiSuggestions.append("Predicted grooming duration: \(duration) minutes")
                aiSuggestions.append("")
                aiSuggestions.append(summary)
            }
        }
    }
    
    private func analyzeClient(_ client: Client) {
        isLoading = true
        aiSuggestions.removeAll()
        
        Task {
            let preferences = await aiService.analyzeClientPreferences(for: client)
            let suggestedTimes = await aiService.suggestOptimalTimes(for: client)
            
            await MainActor.run {
                isLoading = false
                aiSuggestions.append("👤 Client Analysis for \(client.name)")
                aiSuggestions.append("Preferred times: \(preferences.preferredTimes.joined(separator: ", "))")
                aiSuggestions.append("Average spending: $\(String(format: "%.2f", preferences.averageSpending))")
                aiSuggestions.append("Loyalty score: \(Int(preferences.loyaltyScore * 100))%")
                aiSuggestions.append("")
                aiSuggestions.append("Suggested appointment times:")
                for (index, time) in suggestedTimes.enumerated() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .short
                    aiSuggestions.append("\(index + 1). \(dateFormatter.string(from: time))")
                }
            }
        }
    }
    
    private func runAllTests() {
        isLoading = true
        aiSuggestions.removeAll()
        
        // The comprehensive AI test is now available in the AI Test tab.
        // This button now just shows a message.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            aiSuggestions.append("🧪 Please use the 'AI Test' tab for comprehensive AI feature tests.")
        }
    }
}

