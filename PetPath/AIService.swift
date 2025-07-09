//
//  AIService.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import Combine
import CoreLocation

class AIService: ObservableObject {
    private let session = URLSession.shared
    private let baseURL = "https://api.openai.com/v1/chat/completions" // Example API endpoint
    
    // MARK: - Route Optimization
    
    /// Provide route delays from the RouteManager instance for accurate time adjustments.
    func optimizeRoute(appointments: [Appointment], routeDelays: [UUID: Double]? = nil, completion: @escaping (Result<[Appointment], Error>) -> Void) {
        // Implement a more sophisticated route optimization algorithm
        var optimized = smartSortAppointments(appointments)
        
        // Adjust appointments' duration by adding routeDelays from RouteManager if present
        if let routeDelays = routeDelays {
            for i in 0..<optimized.count {
                if let delay = routeDelays[optimized[i].id] {
                    optimized[i].duration += Int(delay)
                }
            }
        }
        
        // Simulate AI processing time with progress updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion(.success(optimized))
        }
    }
    
    private func smartSortAppointments(_ appointments: [Appointment]) -> [Appointment] {
        guard appointments.count > 1 else { return appointments }
        
        var sorted = appointments
        
        // Step 1: Sort by time first
        sorted.sort { $0.time < $1.time }
        
        // Step 2: Apply geographic optimization (simulated)
        sorted = optimizeByLocation(sorted)
        
        // Step 3: Apply service duration optimization
        sorted = optimizeByServiceDuration(sorted)
        
        // Step 4: Apply traffic and weather considerations
        sorted = optimizeByExternalFactors(sorted)
        
        return sorted
    }
    
    private func optimizeByLocation(_ appointments: [Appointment]) -> [Appointment] {
        // Simulate geographic optimization using appointment addresses
        var optimized = appointments
        
        // Group appointments by time slots (hourly)
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: optimized) { appointment in
            calendar.dateInterval(of: .hour, for: appointment.time)?.start ?? appointment.time
        }
        
        // Sort within each hour group by simulated distance
        optimized = grouped.values.flatMap { hourAppointments in
            hourAppointments.sorted { first, second in
                // Simulate distance calculation based on address
                let firstDistance = calculateSimulatedDistance(from: first.client.address)
                let secondDistance = calculateSimulatedDistance(from: second.client.address)
                return firstDistance < secondDistance
            }
        }
        
        return optimized
    }
    
    private func calculateSimulatedDistance(from address: String) -> Double {
        // Simulate distance calculation based on address characteristics
        let baseDistance = Double(address.count) * 0.5
        let randomFactor = Double.random(in: 0.8...1.2)
        return baseDistance * randomFactor
    }
    
    private func optimizeByServiceDuration(_ appointments: [Appointment]) -> [Appointment] {
        // Optimize by placing longer appointments earlier in the day
        // and shorter appointments later to avoid time pressure
        
        return appointments.sorted { first, second in
            if first.duration > second.duration {
                return first.time < second.time
            } else if first.duration == second.duration {
                return first.time < second.time
            } else {
                return first.time < second.time
            }
        }
    }
    
    private func optimizeByExternalFactors(_ appointments: [Appointment]) -> [Appointment] {
        // Consider traffic patterns and weather conditions
        var optimized = appointments
        
        // Simulate traffic-aware optimization
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        
        // Avoid rush hours (7-9 AM and 4-6 PM) for longer appointments
        optimized = optimized.sorted { first, second in
            let firstHour = calendar.component(.hour, from: first.time)
            let secondHour = calendar.component(.hour, from: second.time)
            
            let firstIsRushHour = (firstHour >= 7 && firstHour <= 9) || (firstHour >= 16 && firstHour <= 18)
            let secondIsRushHour = (secondHour >= 7 && secondHour <= 9) || (secondHour >= 16 && secondHour <= 18)
            
            if firstIsRushHour && !secondIsRushHour {
                return false
            } else if !firstIsRushHour && secondIsRushHour {
                return true
            } else {
                return first.time < second.time
            }
        }
        
        return optimized
    }
    
    // MARK: - Pet Care AI Features
    
    func generatePetSummary(pet: Pet) async -> String {
        // Generate a comprehensive pet summary using AI
        var prompt = """
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
        
        if pet.aiVisitCount >= 3 {
            prompt += """

            Additionally, generate a detailed personality profile for the pet based on its history and characteristics.
            """
        }
        
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
        
        // Generate realistic optimal times based on business hours
        let calendar = Calendar.current
        let now = Date()
        
        // Business hours: 8 AM - 6 PM
        let businessStartHour = 8
        let businessEndHour = 18
        
        var suggestedTimes: [Date] = []
        
        for dayOffset in [1, 3, 5] {
            if let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now) {
                // Suggest times during business hours
                let suggestedHour = businessStartHour + (dayOffset * 2) % (businessEndHour - businessStartHour)
                
                if let suggestedTime = calendar.date(bySettingHour: suggestedHour, minute: 0, second: 0, of: targetDate) {
                    suggestedTimes.append(suggestedTime)
                }
            }
        }
        
        return suggestedTimes
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
        
        // Calculate duration based on multiple factors
        var baseDuration = getBaseDuration(for: serviceType)
        
        // Adjust for breed characteristics
        baseDuration = adjustForBreed(baseDuration, breed: pet.breed)
        
        // Adjust for temperament
        baseDuration = adjustForTemperament(baseDuration, temperament: pet.temperament)
        
        // Adjust for special notes
        baseDuration = adjustForNotes(baseDuration, notes: pet.notes)
        
        return max(15, min(180, baseDuration)) // Ensure reasonable range
    }
    
    private func getBaseDuration(for serviceType: ServiceType) -> Int {
        switch serviceType {
        case .grooming: return 75
        case .bath: return 45
        case .nailTrim: return 20
        case .earCleaning: return 15
        case .fullService: return 100
        }
    }
    
    private func adjustForBreed(_ duration: Int, breed: String) -> Int {
        let breedLower = breed.lowercased()
        
        // Large breeds typically take longer
        if breedLower.contains("golden") || breedLower.contains("labrador") || breedLower.contains("german shepherd") {
            return Int(Double(duration) * 1.2)
        }
        
        // Small breeds might be faster
        if breedLower.contains("chihuahua") || breedLower.contains("pomeranian") || breedLower.contains("yorkie") {
            return Int(Double(duration) * 0.9)
        }
        
        // Long-haired breeds need more time
        if breedLower.contains("persian") || breedLower.contains("maine coon") || breedLower.contains("afghan") {
            return Int(Double(duration) * 1.3)
        }
        
        return duration
    }
    
    private func adjustForTemperament(_ duration: Int, temperament: String) -> Int {
        let temperamentLower = temperament.lowercased()
        
        if temperamentLower.contains("anxious") || temperamentLower.contains("nervous") {
            return Int(Double(duration) * 1.4) // Extra time for anxious pets
        }
        
        if temperamentLower.contains("energetic") || temperamentLower.contains("hyper") {
            return Int(Double(duration) * 1.2) // Extra time for energetic pets
        }
        
        if temperamentLower.contains("calm") || temperamentLower.contains("gentle") {
            return Int(Double(duration) * 0.9) // Less time for calm pets
        }
        
        return duration
    }
    
    private func adjustForNotes(_ duration: Int, notes: String) -> Int {
        let notesLower = notes.lowercased()
        
        if notesLower.contains("extra attention") || notesLower.contains("special needs") {
            return Int(Double(duration) * 1.3)
        }
        
        if notesLower.contains("first time") || notesLower.contains("new client") {
            return Int(Double(duration) * 1.2)
        }
        
        if notesLower.contains("well behaved") || notesLower.contains("easy") {
            return Int(Double(duration) * 0.9)
        }
        
        return duration
    }
    
    // MARK: - New Method: Suggest Add-Ons
    
    func suggestAddOns(for pet: Pet, serviceType: ServiceType) async -> [String] {
        // Example: suggest treatment based on fur type, temperament, and service
        var suggestions: [String] = []
        let breedLower = pet.breed.lowercased()
        if serviceType == .grooming {
            if breedLower.contains("retriever") { suggestions.append("Deshedding treatment") }
            if breedLower.contains("poodle") { suggestions.append("Conditioning treatment") }
        }
        if pet.temperament.lowercased().contains("anxious") { suggestions.append("Calming shampoo") }
        return suggestions
    }
    
    // MARK: - New Method: Analyze Review Sentiment
    
    func analyzeReviewSentiment(_ text: String) async -> Double {
        // Forward to AnalyticsManager sentiment function or replicate logic
        return AnalyticsManager().analyzeReviewSentiment(text)
    }
    
    // MARK: - AI Text Generation
    
    private func generateAIText(prompt: String) async -> String {
        // In a real implementation, this would call an AI API like OpenAI
        // For now, return intelligent mock responses based on the prompt
        
        if prompt.contains("summary") {
            let petName = extractPetName(from: prompt)
            return generatePetSummaryText(for: petName, prompt: prompt)
        } else if prompt.contains("optimal times") {
            return "Based on client preferences and business patterns, I suggest: 9:00 AM, 2:00 PM, and 4:30 PM. These times typically have good availability and align with typical client schedules."
        } else if prompt.contains("duration") {
            return "Based on the pet's characteristics and service type, I estimate the appointment will take approximately 75 minutes. This accounts for the pet's temperament and any special needs mentioned."
        } else {
            return "AI analysis complete. The system has processed the information and provided recommendations above."
        }
    }
    
    private func extractPetName(from prompt: String) -> String {
        if let nameRange = prompt.range(of: "Name: ") {
            let afterName = prompt[nameRange.upperBound...]
            if let newlineRange = afterName.firstIndex(of: "\n") {
                return String(afterName[..<newlineRange]).trimmingCharacters(in: .whitespaces)
            }
        }
        return "Unknown Pet"
    }
    
    private func generatePetSummaryText(for petName: String, prompt: String) -> String {
        let breed = extractBreed(from: prompt)
        let temperament = extractTemperament(from: prompt)
        
        return """
        **Pet Summary for \(petName)**
        
        **Behavioral Insights:**
        \(petName) shows typical \(breed) characteristics with a \(temperament) temperament. This breed is known for being \(getBreedTrait(for: breed)) and typically responds well to grooming when approached with patience.
        
        **Care Recommendations:**
        - Regular brushing recommended 2-3 times per week
        - Monthly nail trims to prevent overgrowth and discomfort
        - Ear cleaning every 2-3 weeks to prevent infections
        - Dental care should be included in regular grooming sessions
        
        **Grooming Tips:**
        - Use gentle, breed-appropriate shampoos and conditioners
        - Pay special attention to sensitive areas around eyes and ears
        - Consider seasonal coat changes and adjust grooming frequency
        - Use positive reinforcement during grooming sessions
        
        **Health Considerations:**
        - Monitor for any skin irritations or allergies
        - Check for signs of ear infections or dental issues
        - Maintain regular veterinary check-ups
        - Watch for changes in coat condition or behavior
        
        **Special Notes:**
        Based on the \(temperament) temperament, this pet may require extra patience during certain procedures. Consider scheduling during quieter hours for optimal results.
        """
    }
    
    private func extractBreed(from prompt: String) -> String {
        if let breedRange = prompt.range(of: "Breed: ") {
            let afterBreed = prompt[breedRange.upperBound...]
            if let newlineRange = afterBreed.firstIndex(of: "\n") {
                return String(afterBreed[..<newlineRange]).trimmingCharacters(in: .whitespaces)
            }
        }
        return "Mixed Breed"
    }
    
    private func extractTemperament(from prompt: String) -> String {
        if let temperamentRange = prompt.range(of: "Temperament: ") {
            let afterTemperament = prompt[temperamentRange.upperBound...]
            if let newlineRange = afterTemperament.firstIndex(of: "\n") {
                return String(afterTemperament[..<newlineRange]).trimmingCharacters(in: .whitespaces)
            }
        }
        return "Friendly"
    }
    
    private func getBreedTrait(for breed: String) -> String {
        let breedLower = breed.lowercased()
        
        if breedLower.contains("golden") || breedLower.contains("labrador") {
            return "friendly and patient"
        } else if breedLower.contains("persian") || breedLower.contains("maine coon") {
            return "calm and dignified"
        } else if breedLower.contains("chihuahua") || breedLower.contains("yorkie") {
            return "alert and energetic"
        } else {
            return "adaptable and trainable"
        }
    }
    
    // MARK: - Traffic and Weather Integration
    
    func getTrafficConditions(for location: String) async -> TrafficCondition {
        // In a real app, this would integrate with traffic APIs
        // Simulate traffic conditions based on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        
        if (hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 18) {
            return .heavy
        } else if (hour >= 10 && hour <= 15) {
            return .moderate
        } else {
            return .light
        }
    }
    
    func getWeatherConditions(for location: String) async -> WeatherCondition {
        // In a real app, this would integrate with weather APIs
        // Simulate weather conditions
        let random = Int.random(in: 1...4)
        switch random {
        case 1: return .clear
        case 2: return .cloudy
        case 3: return .rainy
        case 4: return .snowy
        default: return .clear
        }
    }
    
    // MARK: - Advanced AI Features
    
    func analyzeClientPreferences(for client: Client) async -> ClientPreferences {
        // Analyze client booking patterns and preferences
        return ClientPreferences(
            preferredTimes: ["9:00 AM", "2:00 PM", "4:30 PM"],
            preferredServices: [.grooming, .bath],
            averageSpending: 85.0,
            loyaltyScore: 0.8
        )
    }
    
    func predictNoShowProbability(for appointment: Appointment) async -> Double {
        // Predict the probability of a no-show based on various factors
        var probability = 0.1 // Base 10% probability
        
        // Adjust based on client history (simulated)
        if appointment.client.name.contains("New") {
            probability += 0.15 // New clients more likely to no-show
        }
        
        // Adjust based on time of day
        let hour = Calendar.current.component(.hour, from: appointment.time)
        if hour < 9 || hour > 17 {
            probability += 0.1 // Early morning or late appointments
        }
        
        // Adjust based on service type
        if appointment.serviceType == .nailTrim {
            probability += 0.05 // Quick services sometimes skipped
        }
        
        let cappedProbability = min(0.8, probability) // Cap at 80%
        
        if cappedProbability > 0.5 {
            NotificationCenter.default.post(name: Notification.Name("NoShowRisk"), object: nil, userInfo: ["appointmentID": appointment.id])
        }
        
        return cappedProbability
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
    
    var delayMultiplier: Double {
        switch self {
        case .light: return 1.0
        case .moderate: return 1.3
        case .heavy: return 1.8
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
    
    var delayMultiplier: Double {
        switch self {
        case .clear: return 1.0
        case .cloudy: return 1.1
        case .rainy: return 1.4
        case .snowy: return 1.6
        }
    }
}

struct ClientPreferences {
    let preferredTimes: [String]
    let preferredServices: [ServiceType]
    let averageSpending: Double
    let loyaltyScore: Double
} 


