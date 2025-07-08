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
    
    private let analyticsManager: AnalyticsManager
    
    init(analyticsManager: AnalyticsManager) {
        self.analyticsManager = analyticsManager
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
        let previousRouteDistance = calculateRouteDistance(optimizedRoute)
        
        // Simple sorting for now - will add AI later
        optimizedRoute = appointments.sorted(by: { $0.time < $1.time })
        
        let optimizedRouteDistance = calculateRouteDistance(optimizedRoute)
        
        // Track analytics if route was actually optimized
        if !appointments.isEmpty && previousRouteDistance > optimizedRouteDistance {
            let milesSaved = previousRouteDistance - optimizedRouteDistance
            let timeSaved = milesSaved / 35.0 // Assume 35 mph average speed
            let fuelSaved = milesSaved * 0.15 * 3.50 // Assume 15 miles per gallon, $3.50 per gallon
            
            analyticsManager.trackMileageSaved(milesSaved)
            analyticsManager.trackTimeSaved(timeSaved)
            analyticsManager.trackFuelSaved(fuelSaved)
        }
    }
    
    func completeAppointment(_ appointment: Appointment) {
        analyticsManager.trackAppointmentCompleted()
        deleteAppointment(appointment)
    }
    
    private func calculateRouteDistance(_ route: [Appointment]) -> Double {
        // Simple distance calculation - in a real app, this would use actual GPS coordinates
        // For now, simulate based on number of appointments and random factors
        guard !route.isEmpty else { return 0.0 }
        
        let baseDistance = Double(route.count) * 5.0 // 5 miles per appointment
        let randomFactor = Double.random(in: 0.8...1.2) // Add some variation
        
        return baseDistance * randomFactor
    }
    
    func clearAllAppointments() {
        appointments.removeAll()
        optimizedRoute.removeAll()
        saveData()
    }
    
    func getTotalAppointments() -> Int {
        return appointments.count
    }
    
    func getTodaysAppointments() -> [Appointment] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return appointments.filter { appointment in
            appointment.time >= today && appointment.time < tomorrow
        }
    }
} 