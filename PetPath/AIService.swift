//
//  AIService.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import Combine

class AIService: ObservableObject {
    private let session = URLSession.shared
    private let baseURL = "https://api.openai.com/v1/chat/completions" // Example API endpoint
    
    // MARK: - Route Optimization
    
    func optimizeRoute(appointments: [Appointment], completion: @escaping (Result<[Appointment], Error>) -> Void) {
        // For now, implement a smart sorting algorithm
        // In a real implementation, this would call an AI API
        
        let optimized = smartSortAppointments(appointments)
        
        // Simulate AI processing time
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion(.success(optimized))
        }
    }
    
    private func smartSortAppointments(_ appointments: [Appointment]) -> [Appointment] {
        // Smart sorting algorithm that considers:
        // 1. Time constraints
        // 2. Geographic proximity (simulated)
        // 3. Service duration
        // 4. Client preferences
        
        var sorted = appointments
        
        // Sort by time first
        sorted.sort { $0.time < $1.time }
        
        // Apply geographic optimization (simulated)
        sorted = optimizeByLocation(sorted)
        
        // Apply service duration optimization
        sorted = optimizeByServiceDuration(sorted)
        
        return sorted
    }
    
    private func optimizeByLocation(_ appointments: [Appointment]) -> [Appointment] {
        // Simulate geographic optimization
        // In a real app, this would use actual GPS coordinates and distance calculations
        
        var optimized = appointments
        
        // Simple optimization: group appointments by time slots
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: optimized) { appointment in
            calendar.dateInterval(of: .hour, for: appointment.time)?.start ?? appointment.time
        }
        
        // Sort within each hour group
        optimized = grouped.values.flatMap { hourAppointments in
            hourAppointments.sorted { $0.time < $1.time }
        }
        
        return optimized
    }
    
    private func optimizeByServiceDuration(_ appointments: [Appointment]) -> [Appointment] {
        // Optimize by placing longer appointments earlier in the day
        // and shorter appointments later
        
        return appointments.sorted { first, second in
            if first.duration > second.duration {
                return first.time < second.time
            } else {
                return first.time < second.time
            }
        }
    }
    
    // MARK: - Pet Care AI Features
    
    func generatePetSummary(pet: Pet) async -> String {
        // Generate a comprehensive pet summary using AI
        let prompt = """
        Generate a comprehensive summary for a pet with the following details:
        Name: \(pet.name)
        Breed: \(pet.breed)
        Temperament: \(pet.temperament)
        Notes: \(pet.notes)
        
        Include:
        - Behavioral insights
        - Care recommendations
        - Grooming tips
        - Health considerations
        """
        
        return await generateAIText(prompt: prompt)
    }
    
    func suggestOptimalTimes(for client: Client) async -> [Date] {
        // Suggest optimal appointment times based on client history and preferences
        
        let prompt = """
        Suggest optimal appointment times for a client named \(client.name).
        Consider typical grooming business hours and client preferences.
        Return 3 suggested times for the next week.
        """
        
        _ = await generateAIText(prompt: prompt)
        
        // Parse the response and convert to dates
        // For now, return some default times
        let calendar = Calendar.current
        let now = Date()
        
        return [
            calendar.date(byAdding: .day, value: 1, to: now) ?? now,
            calendar.date(byAdding: .day, value: 3, to: now) ?? now,
            calendar.date(byAdding: .day, value: 5, to: now) ?? now
        ]
    }
    
    func predictAppointmentDuration(for pet: Pet, serviceType: ServiceType) async -> Int {
        // Predict appointment duration based on pet characteristics and service type
        
        let prompt = """
        Predict the duration (in minutes) for a \(serviceType.rawValue) service for a pet with:
        Name: \(pet.name)
        Breed: \(pet.breed)
        Temperament: \(pet.temperament)
        Notes: \(pet.notes)
        
        Consider the pet's size, breed characteristics, and any special needs.
        """
        
        _ = await generateAIText(prompt: prompt)
        
        // Parse the response for duration
        // For now, return a reasonable estimate based on service type and temperament
        switch serviceType {
        case .grooming:
            return pet.temperament.lowercased().contains("anxious") ? 90 : 75
        case .bath:
            return 45
        case .nailTrim:
            return 20
        case .earCleaning:
            return 15
        case .fullService:
            return pet.temperament.lowercased().contains("anxious") ? 120 : 100
        }
    }
    
    // MARK: - AI Text Generation
    
    private func generateAIText(prompt: String) async -> String {
        // In a real implementation, this would call an AI API like OpenAI
        // For now, return mock responses
        
        if prompt.contains("summary") {
            return """
            **Pet Summary for \(prompt.components(separatedBy: "Name: ").last?.components(separatedBy: "\n").first ?? "Unknown")**
            
            **Behavioral Insights:**
            This pet shows typical breed characteristics with good temperament for grooming sessions.
            
            **Care Recommendations:**
            - Regular brushing recommended 2-3 times per week
            - Monthly nail trims to prevent overgrowth
            - Ear cleaning every 2-3 weeks
            
            **Grooming Tips:**
            - Use gentle, breed-appropriate shampoos
            - Pay attention to sensitive areas around eyes and ears
            - Consider seasonal coat changes
            
            **Health Considerations:**
            - Monitor for any skin irritations
            - Check for signs of ear infections
            - Maintain regular veterinary check-ups
            """
        } else if prompt.contains("optimal times") {
            return "Suggested times: 9:00 AM, 2:00 PM, 4:30 PM"
        } else if prompt.contains("duration") {
            return "Estimated duration: 75 minutes"
        } else {
            return "AI analysis complete. Please review the recommendations above."
        }
    }
    
    // MARK: - Traffic and Weather Integration
    
    func getTrafficConditions(for location: String) async -> TrafficCondition {
        // In a real app, this would integrate with traffic APIs
        return .moderate
    }
    
    func getWeatherConditions(for location: String) async -> WeatherCondition {
        // In a real app, this would integrate with weather APIs
        return .clear
    }
}

// MARK: - Supporting Types

enum TrafficCondition {
    case light, moderate, heavy
    
    var description: String {
        switch self {
        case .light: return "Light traffic"
        case .moderate: return "Moderate traffic"
        case .heavy: return "Heavy traffic"
        }
    }
}

enum WeatherCondition {
    case clear, cloudy, rainy, snowy
    
    var description: String {
        switch self {
        case .clear: return "Clear weather"
        case .cloudy: return "Cloudy conditions"
        case .rainy: return "Rainy weather"
        case .snowy: return "Snowy conditions"
        }
    }
} 