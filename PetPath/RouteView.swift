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
                                    AppointmentRow(appointment: appointment)
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
                                    AppointmentRow(appointment: appointment)
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
            }
            .navigationTitle("Route")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAppointment = true }) {
                        Image(systemName: "plus")
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
        }
        .padding(.vertical, 4)
    }
}

struct AIFeaturesView: View {
    @EnvironmentObject var clientManager: ClientManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedClient: Client?
    @State private var selectedPet: Pet?
    @State private var aiSuggestions: [String] = []
    @State private var isLoading = false
    
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
                    }
                }
                
                Section("Pet Behavior Analysis") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Predictive Pet Care")
                            .font(.headline)
                        Text("AI analyzes pet behavior patterns to suggest optimal appointment times and service durations.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Client Preferences") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personalized Scheduling")
                            .font(.headline)
                        Text("AI learns client preferences and suggests appointment times that work best for each client.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !aiSuggestions.isEmpty {
                    Section("AI Suggestions") {
                        ForEach(aiSuggestions, id: \.self) { suggestion in
                            Text(suggestion)
                                .font(.caption)
                        }
                    }
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
        }
    }
}
