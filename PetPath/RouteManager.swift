//
//  RouteManager.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI
import Combine

class RouteManager: ObservableObject {
    @Published var appointments: [Appointment] = []
    @Published var optimizedRoute: [Appointment] = []
    @Published var isOptimizing = false
    @Published var optimizationProgress: Double = 0.0
    
    private let analyticsManager: AnalyticsManager
    private let aiService = AIService()
    
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
        guard !appointments.isEmpty else {
            optimizedRoute = []
            return
        }
        
        let previousRouteDistance = calculateRouteDistance(optimizedRoute)
        
        // Use AI optimization if available, otherwise fall back to simple sorting
        if appointments.count > 3 {
            optimizeWithAI()
        } else {
            // Simple sorting for small numbers of appointments
            optimizedRoute = appointments.sorted(by: { $0.time < $1.time })
            trackOptimizationResults(previousDistance: previousRouteDistance)
        }
    }
    
    private func optimizeWithAI() {
        isOptimizing = true
        optimizationProgress = 0.0
        
        aiService.optimizeRoute(appointments: appointments) { [weak self] result in
            DispatchQueue.main.async {
                self?.isOptimizing = false
                self?.optimizationProgress = 1.0
                
                switch result {
                case .success(let optimizedAppointments):
                    self?.optimizedRoute = optimizedAppointments
                    self?.trackOptimizationResults(previousDistance: self?.calculateRouteDistance(self?.appointments ?? []) ?? 0)
                case .failure(let error):
                    print("AI optimization failed: \(error.localizedDescription)")
                    // Fall back to simple sorting
                    self?.optimizedRoute = self?.appointments.sorted(by: { $0.time < $1.time }) ?? []
                }
            }
        }
    }
    
    private func trackOptimizationResults(previousDistance: Double) {
        let optimizedRouteDistance = calculateRouteDistance(optimizedRoute)
        
        // Track analytics if route was actually optimized
        if !appointments.isEmpty && previousDistance > optimizedRouteDistance {
            let milesSaved = previousDistance - optimizedRouteDistance
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
    
    // MARK: - AI Features
    
    func generatePetSummary(for pet: Pet) async -> String {
        return await aiService.generatePetSummary(pet: pet)
    }
    
    func suggestOptimalTimes(for client: Client) async -> [Date] {
        return await aiService.suggestOptimalTimes(for: client)
    }
    
    func predictAppointmentDuration(for pet: Pet, serviceType: ServiceType) async -> Int {
        return await aiService.predictAppointmentDuration(for: pet, serviceType: serviceType)
    }
}
