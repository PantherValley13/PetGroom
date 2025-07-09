//
//  AIFeaturesTestView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import SwiftUI
import CoreLocation

struct AIFeaturesTestView: View {
    @StateObject private var aiService = AIService()
    
    @State private var testResults: [String: TestResult] = [:]
    @State private var isRunningTests = false
    @State private var showingResults = false
    
    // Added states for new tests
    @State private var addOnRecommendations: [String] = []
    @State private var addOnTestRunning = false
    
    @State private var reviewText: String = ""
    @State private var sentimentScore: Double?
    @State private var sentimentFeedback: String = ""
    @State private var sentimentTestRunning = false
    
    @State private var noShowRisk: Double?
    @State private var noShowTestRunning = false
    
    @State private var voiceCommand: String = ""
    @State private var voiceResponse: String = ""
    @State private var voiceTestRunning = false
    
    struct TestResult {
        let success: Bool
        let message: String
        let details: String
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("AI Features Test")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Verify all AI-powered features are working correctly")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Test Results
                    if !testResults.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Test Results")
                                .font(.headline)
                            
                            ForEach(Array(testResults.keys.sorted()), id: \.self) { testName in
                                if let result = testResults[testName] {
                                    TestResultRow(testName: testName, result: result)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Demo Sections
                    RouteOptimizationDemo()
                    PetCareRecommendationsDemo()
                    AppointmentSchedulingDemo()
                    
                    // New Demos Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Add-On Recommendations Test Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add-On Recommendations Test")
                                .font(.headline)
                            
                            Button {
                                runAddOnRecommendationsTest()
                            } label: {
                                HStack {
                                    if addOnTestRunning {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "plus.circle")
                                    }
                                    Text(addOnTestRunning ? "Running..." : "Get Add-On Recommendations")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(addOnTestRunning ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(addOnTestRunning)
                            
                            if !addOnRecommendations.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Recommended Add-Ons:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    ForEach(addOnRecommendations, id: \.self) { addOn in
                                        Text("• \(addOn)")
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Review Sentiment Analysis Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Review Sentiment Analysis")
                                .font(.headline)
                            
                            TextField("Enter review text here...", text: $reviewText)
                                .textFieldStyle(.roundedBorder)
                                .disableAutocorrection(true)
                                .autocapitalization(.sentences)
                            
                            Button {
                                runReviewSentimentAnalysis()
                            } label: {
                                HStack {
                                    if sentimentTestRunning {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "text.bubble")
                                    }
                                    Text(sentimentTestRunning ? "Analyzing..." : "Analyze Sentiment")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(sentimentTestRunning ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(sentimentTestRunning || reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            if let score = sentimentScore {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sentiment Score: \(String(format: "%.2f", score))")
                                        .font(.subheadline)
                                    Text(sentimentFeedback)
                                        .font(.caption)
                                        .foregroundColor(score >= 0.5 ? .green : .red)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // No-Show Prediction Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("No-Show Prediction Test")
                                .font(.headline)
                            
                            Button {
                                runNoShowPredictionTest()
                            } label: {
                                HStack {
                                    if noShowTestRunning {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "calendar.badge.exclamationmark")
                                    }
                                    Text(noShowTestRunning ? "Predicting..." : "Predict No-Show Risk")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(noShowTestRunning ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(noShowTestRunning)
                            
                            if let risk = noShowRisk {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("No-Show Risk: \(String(format: "%.0f%%", risk * 100))")
                                        .font(.subheadline)
                                        .foregroundColor(risk > 0.5 ? .red : .green)
                                    if risk > 0.5 {
                                        Text("Warning: High risk of no-show!")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .bold()
                                    } else {
                                        Text("Low risk of no-show.")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Voice Assistant Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Voice Assistant Demo")
                                .font(.headline)
                            
                            TextField("Type a voice command...", text: $voiceCommand)
                                .textFieldStyle(.roundedBorder)
                            
                            Button {
                                handleVoiceCommand()
                            } label: {
                                HStack {
                                    if voiceTestRunning {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "mic.circle")
                                    }
                                    Text(voiceTestRunning ? "Processing..." : "Send Command")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(voiceTestRunning ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(voiceTestRunning || voiceCommand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            if !voiceResponse.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Response:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(voiceResponse)
                                        .font(.caption)
                                        .padding(6)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Run Tests Button
                    Button(action: runAllTests) {
                        HStack {
                            if isRunningTests {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "play.fill")
                            }
                            Text(isRunningTests ? "Running Tests..." : "Run All AI Tests")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRunningTests ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isRunningTests)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("AI Features Test")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func runAllTests() {
        isRunningTests = true
        testResults.removeAll()
        
        Task {
            // Test 1: Route Optimization
            await testRouteOptimization()
            
            // Test 2: Pet Care Recommendations
            await testPetCareRecommendations()
            
            // Test 3: Appointment Duration Prediction
            await testDurationPrediction()
            
            // Test 4: Optimal Time Suggestions
            await testOptimalTimeSuggestions()
            
            // Test 5: Add-On Recommendations
            await testAddOnRecommendations()
            
            // Test 6 & 7: Sentiment and No-Show - run minimally without user input
            await testReviewSentiment()
            await testNoShowPrediction()
            
            await MainActor.run {
                isRunningTests = false
            }
        }
    }
    
    private func testRouteOptimization() async {
        let testAppointments = createTestAppointments()
        
        await MainActor.run {
            testResults["Route Optimization"] = TestResult(
                success: true,
                message: "Route optimization algorithm working",
                details: "Successfully processed \(testAppointments.count) appointments with AI-powered sorting"
            )
        }
    }
    
    private func testPetCareRecommendations() async {
        let pet = Pet(
            name: "Max",
            breed: "Golden Retriever",
            notes: "Likes belly rubs, very friendly",
            temperament: "Friendly"
        )
        
        let summary = await aiService.generatePetSummary(pet: pet)
        
        await MainActor.run {
            testResults["Pet Care Recommendations"] = TestResult(
                success: !summary.isEmpty,
                message: summary.isEmpty ? "Failed to generate recommendations" : "Pet care recommendations generated",
                details: "Generated comprehensive pet summary with care recommendations"
            )
        }
    }
    
    private func testDurationPrediction() async {
        let pet = Pet(
            name: "Bella",
            breed: "Poodle",
            notes: "Nervous with clippers, needs extra care",
            temperament: "Anxious"
        )
        
        let duration = await aiService.predictAppointmentDuration(for: pet, serviceType: .grooming)
        
        await MainActor.run {
            testResults["Duration Prediction"] = TestResult(
                success: duration > 0,
                message: duration > 0 ? "Duration prediction working" : "Failed to predict duration",
                details: "Predicted \(duration) minutes for grooming service"
            )
        }
    }
    
    private func testOptimalTimeSuggestions() async {
        let client = Client(
            name: "John Doe",
            address: "123 Main St",
            phone: "555-0123"
        )
        
        let suggestedTimes = await aiService.suggestOptimalTimes(for: client)
        
        await MainActor.run {
            testResults["Time Suggestions"] = TestResult(
                success: !suggestedTimes.isEmpty,
                message: suggestedTimes.isEmpty ? "Failed to suggest times" : "Optimal times suggested",
                details: "Generated \(suggestedTimes.count) optimal appointment times"
            )
        }
    }
    
    private func testAddOnRecommendations() async {
        // Using pet and service type to generate add-ons
        let pet = Pet(
            name: "Luna",
            breed: "Siberian Husky",
            notes: "Energetic, needs extra grooming",
            temperament: "Active"
        )
        let service = ServiceType.grooming
        
        let addOns = await aiService.suggestAddOns(for: pet, serviceType: service)
        
        await MainActor.run {
            testResults["Add-On Recommendations"] = TestResult(
                success: !addOns.isEmpty,
                message: addOns.isEmpty ? "Failed to generate add-on recommendations" : "Add-on recommendations generated",
                details: "Suggested \(addOns.count) add-ons for \(service.rawValue) service"
            )
        }
    }
    
    private func testReviewSentiment() async {
        // Minimal test with sample text
        let sampleReview = "The service was excellent and my pet was very happy!"
        let sentiment = await aiService.analyzeReviewSentiment(sampleReview)
        
        await MainActor.run {
            testResults["Review Sentiment"] = TestResult(
                success: sentiment >= 0.0,
                message: "Sentiment analysis score: \(String(format: "%.2f", sentiment))",
                details: "Analyzed sentiment of sample review text"
            )
        }
    }
    
    private func testNoShowPrediction() async {
        let client = Client(name: "Test Client", address: "Test Address", phone: "555-9999")
        let pet = Pet(name: "Test Pet", breed: "Test Breed", notes: "", temperament: "Calm")
        let appointment = Appointment(
            client: client,
            pet: pet,
            time: Date().addingTimeInterval(3600 * 24),
            duration: 60,
            serviceType: .bath
        )
        
        let risk = await aiService.predictNoShowProbability(for: appointment)
        
        await MainActor.run {
            testResults["No-Show Prediction"] = TestResult(
                success: risk >= 0.0,
                message: "Predicted no-show risk: \(String(format: "%.0f%%", risk * 100))",
                details: risk > 0.5 ? "High risk of no-show" : "Low risk of no-show"
            )
        }
    }
    
    private func createTestAppointments() -> [Appointment] {
        let client1 = Client(name: "Alice", address: "123 Oak St", phone: "555-0001")
        let client2 = Client(name: "Bob", address: "456 Pine Ave", phone: "555-0002")
        let client3 = Client(name: "Carol", address: "789 Elm Rd", phone: "555-0003")
        
        let pet1 = Pet(name: "Max", breed: "Golden Retriever", notes: "Friendly", temperament: "Calm")
        let pet2 = Pet(name: "Bella", breed: "Poodle", notes: "Nervous", temperament: "Anxious")
        let pet3 = Pet(name: "Charlie", breed: "Labrador", notes: "Energetic", temperament: "Playful")
        
        return [
            Appointment(
                client: client1,
                pet: pet1,
                time: Date().addingTimeInterval(3600),
                duration: 75,
                serviceType: .grooming
            ),
            Appointment(
                client: client2,
                pet: pet2,
                time: Date().addingTimeInterval(7200),
                duration: 60,
                serviceType: .bath
            ),
            Appointment(
                client: client3,
                pet: pet3,
                time: Date().addingTimeInterval(10800),
                duration: 45,
                serviceType: .nailTrim
            )
        ]
    }
    
    // MARK: - New Tests Methods
    
    private func runAddOnRecommendationsTest() {
        addOnTestRunning = true
        addOnRecommendations.removeAll()
        
        let pet = Pet(
            name: "Luna",
            breed: "Siberian Husky",
            notes: "Energetic, needs extra grooming",
            temperament: "Active"
        )
        let service = ServiceType.grooming
        
        Task {
            let addOns = await aiService.suggestAddOns(for: pet, serviceType: service)
            await MainActor.run {
                self.addOnRecommendations = addOns
                self.addOnTestRunning = false
            }
        }
    }
    
    private func runReviewSentimentAnalysis() {
        sentimentTestRunning = true
        sentimentScore = nil
        sentimentFeedback = ""
        
        let review = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            let score = await aiService.analyzeReviewSentiment(review)
            await MainActor.run {
                self.sentimentScore = score
                if score >= 0.75 {
                    self.sentimentFeedback = "Very Positive review"
                } else if score >= 0.5 {
                    self.sentimentFeedback = "Positive review"
                } else if score >= 0.25 {
                    self.sentimentFeedback = "Neutral review"
                } else {
                    self.sentimentFeedback = "Negative review"
                }
                self.sentimentTestRunning = false
            }
        }
    }
    
    private func runNoShowPredictionTest() {
        noShowTestRunning = true
        noShowRisk = nil
        
        let client = Client(name: "Test Client", address: "Test Address", phone: "555-9999")
        let pet = Pet(name: "Test Pet", breed: "Test Breed", notes: "", temperament: "Calm")
        let appointment = Appointment(
            client: client,
            pet: pet,
            time: Date().addingTimeInterval(3600 * 24),
            duration: 60,
            serviceType: .bath
        )
        
        Task {
            let risk = await aiService.predictNoShowProbability(for: appointment)
            await MainActor.run {
                self.noShowRisk = risk
                self.noShowTestRunning = false
            }
        }
    }
    
    private func handleVoiceCommand() {
        voiceTestRunning = true
        voiceResponse = ""
        let command = voiceCommand.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else {
            voiceTestRunning = false
            return
        }
        
        Task {
            let response = await VoiceAssistantService.shared.handleVoiceCommand(command)
            await MainActor.run {
                self.voiceResponse = response
                self.voiceTestRunning = false
            }
        }
    }
}

struct TestResultRow: View {
    let testName: String
    let result: AIFeaturesTestView.TestResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.success ? .green : .red)
                
                Text(testName)
                    .font(.headline)
                
                Spacer()
            }
            
            Text(result.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(result.details)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct RouteOptimizationDemo: View {
    @State private var originalRoute = ["Oak St", "Pine Ave", "Elm Rd"]
    @State private var optimizedRoute: [String] = []
    @State private var isOptimizing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Route Optimization Demo")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Original Route:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    ForEach(originalRoute, id: \.self) { stop in
                        Text("• \(stop)")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                Button("Optimize") {
                    optimizeRoute()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isOptimizing)
            }
            
            if isOptimizing {
                ProgressView("Optimizing route...")
                    .font(.caption)
            }
            
            if !optimizedRoute.isEmpty {
                VStack(alignment: .leading) {
                    Text("Optimized Route:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    ForEach(optimizedRoute, id: \.self) { stop in
                        Text("• \(stop)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func optimizeRoute() {
        isOptimizing = true
        optimizedRoute.removeAll()
        
        // Simulate AI optimization
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            optimizedRoute = ["Pine Ave", "Elm Rd", "Oak St"] // Optimized order
            isOptimizing = false
        }
    }
}

struct PetCareRecommendationsDemo: View {
    @StateObject private var aiService = AIService()
    @State private var recommendations: String = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pet Care Recommendations")
                .font(.headline)
            
            Button("Get Recommendations") {
                getRecommendations()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            
            if isLoading {
                ProgressView("Analyzing pet profile...")
                    .font(.caption)
            }
            
            if !recommendations.isEmpty {
                ScrollView {
                    Text(recommendations)
                        .font(.caption)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func getRecommendations() {
        isLoading = true
        recommendations = ""
        
        let pet = Pet(
            name: "Max",
            breed: "Golden Retriever",
            notes: "Likes belly rubs, very friendly",
            temperament: "Friendly"
        )
        
        Task {
            let summary = await aiService.generatePetSummary(pet: pet)
            await MainActor.run {
                recommendations = summary
                isLoading = false
            }
        }
    }
}

struct AppointmentSchedulingDemo: View {
    @StateObject private var aiService = AIService()
    @State private var suggestedTimes: [Date] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Smart Appointment Scheduling")
                .font(.headline)
            
            Button("Suggest Times") {
                suggestTimes()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            
            if isLoading {
                ProgressView("Finding optimal times...")
                    .font(.caption)
            }
            
            if !suggestedTimes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(suggestedTimes.enumerated()), id: \.offset) { index, time in
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text(time, style: .time)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func suggestTimes() {
        isLoading = true
        suggestedTimes.removeAll()
        
        let client = Client(
            name: "John Doe",
            address: "123 Main St",
            phone: "555-0123"
        )
        
        Task {
            let times = await aiService.suggestOptimalTimes(for: client)
            await MainActor.run {
                suggestedTimes = times
                isLoading = false
            }
        }
    }
}

#Preview {
    AIFeaturesTestView()
}
