//
//  RouteView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct RouteView: View {
    @StateObject private var routeService = RouteService()
    
    var body: some View {
        NavigationView {
            VStack {
                // Map placeholder
                ZStack {
                    Color.gray.opacity(0.2)
                    Text("Map View")
                        .foregroundColor(.secondary)
                }
                .frame(height: 250)
                .cornerRadius(12)
                .padding()
                
                Button(action: {
                    routeService.optimizeRoute()
                }) {
                    Label("Optimize Today's Route", systemImage: "arrow.triangle.merge")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                List {
                    Section("Today's Appointments") {
                        ForEach(routeService.appointments) { appointment in
                            AppointmentRow(appointment: appointment)
                        }
                    }
                }
            }
            .navigationTitle("Today's Route")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "ellipsis.circle")
                    }
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
            Text(appointment.time, style: .time)
        }
    }
}
