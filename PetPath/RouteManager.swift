//
//  RouteManager.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

class RouteManager: ObservableObject {
    @Published var appointments: [Appointment] = []
    @Published var optimizedRoute: [Appointment] = []
    
    init() {
        loadData()
        optimizeRoute()
    }
    
    private func loadData() {
        // Load saved data first
        if let savedAppointments: [Appointment] = Persistence.shared.load([Appointment].self, for: "appointments") {
            appointments = savedAppointments
        } else {
            // If no saved data, load sample data
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        appointments = Appointment.sample
        saveData()
    }
    
    private func saveData() {
        Persistence.shared.save(appointments, for: "appointments")
    }
    
    func addAppointment(_ appointment: Appointment) {
        appointments.append(appointment)
        saveData()
        optimizeRoute()
    }
    
    func deleteAppointment(_ appointment: Appointment) {
        appointments.removeAll { $0.id == appointment.id }
        saveData()
        optimizeRoute()
    }
    
    func updateAppointment(_ appointment: Appointment) {
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            appointments[index] = appointment
            saveData()
            optimizeRoute()
        }
    }
    
    func optimizeRoute() {
        // Simple sorting for now - will add AI later
        optimizedRoute = appointments.sorted(by: { $0.time < $1.time })
    }
    
    func clearAllAppointments() {
        appointments.removeAll()
        optimizedRoute.removeAll()
        saveData()
    }
} 