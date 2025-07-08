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
                
                // Route optimization button
                Button("Optimize Route", action: {
                    routeManager?.optimizeRoute()
                })
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Appointments list
                if let routeManager = routeManager {
                    List {
                        Section("Optimized Route") {
                            if routeManager.optimizedRoute.isEmpty {
                                Text("No appointments scheduled")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            } else {
                                ForEach(routeManager.optimizedRoute) { appointment in
                                    AppointmentRow(appointment: appointment)
                                        .swipeActions(edge: .trailing) {
                                            Button("Complete") {
                                                routeManager.completeAppointment(appointment)
                                            }
                                            .tint(.green)
                                        }
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                    ProgressView("Loading appointments...")
                    Spacer()
                }
            }
            .navigationTitle("Today's Route")
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
            .onAppear {
                if routeManager == nil {
                    routeManager = RouteManager(analyticsManager: analyticsManager)
                }
            }
        }
    }
}

struct AppointmentRow: View {
    let appointment: Appointment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(appointment.clientName)
                    .font(.headline)
                Text(appointment.petName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(appointment.time, style: .time)
                Text("\(appointment.duration) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
