//
//  SettingsView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var clientManager: ClientManager
    @EnvironmentObject var analyticsManager: AnalyticsManager
    
    @State private var showingBusinessHours = false
    @State private var showingServiceTypes = false
    @State private var showingPricing = false
    @State private var showingExportData = false
    @State private var showingDeleteAccount = false
    @State private var showingAbout = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    // App Settings
    @AppStorage("businessName") private var businessName = "PetPath Grooming"
    @AppStorage("businessPhone") private var businessPhone = ""
    @AppStorage("businessEmail") private var businessEmail = ""
    @AppStorage("businessAddress") private var businessAddress = ""
    @AppStorage("defaultAppointmentDuration") private var defaultDuration = 60
    @AppStorage("enableAIFeatures") private var enableAIFeatures = true
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("enableLocationTracking") private var enableLocationTracking = true
    @AppStorage("appTheme") private var appTheme = "System"
    @AppStorage("enableAnalytics") private var enableAnalytics = true
    @AppStorage("enableCrashReporting") private var enableCrashReporting = true
    
    var body: some View {
        NavigationView {
            List {
                // Business Information Section
                Section("Business Information") {
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Business Name")
                                .font(.headline)
                            Text(businessName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Edit") {
                            // TODO: Add edit business info sheet
                        }
                        .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Image(systemName: "phone")
                            .foregroundColor(.green)
                        Text("Phone")
                        Spacer()
                        Text(businessPhone.isEmpty ? "Not set" : businessPhone)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.orange)
                        Text("Email")
                        Spacer()
                        Text(businessEmail.isEmpty ? "Not set" : businessEmail)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.red)
                        Text("Address")
                        Spacer()
                        Text(businessAddress.isEmpty ? "Not set" : businessAddress)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Business Operations Section
                Section("Business Operations") {
                    NavigationLink(destination: BusinessHoursView()) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.purple)
                            Text("Business Hours")
                        }
                    }
                    
                    NavigationLink(destination: ServiceTypesView()) {
                        HStack {
                            Image(systemName: "scissors")
                                .foregroundColor(.indigo)
                            Text("Service Types")
                        }
                    }
                    
                    NavigationLink(destination: PricingView()) {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.green)
                            Text("Pricing")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                        Text("Default Appointment Duration")
                        Spacer()
                        Text("\(defaultDuration) minutes")
                            .foregroundColor(.secondary)
                    }
                }
                
                // AI Features Section
                Section("AI Features") {
                    Toggle(isOn: $enableAIFeatures) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                            Text("Enable AI Features")
                        }
                    }
                    
                    if enableAIFeatures {
                        NavigationLink(destination: AIPreferencesView()) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.orange)
                                Text("AI Preferences")
                            }
                        }
                        
                        NavigationLink(destination: AIFeaturesTestView()) {
                            HStack {
                                Image(systemName: "testtube.2")
                                    .foregroundColor(.blue)
                                Text("Test AI Features")
                            }
                        }
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle(isOn: $enableNotifications) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.red)
                            Text("Enable Notifications")
                        }
                    }
                    
                    if enableNotifications {
                        NavigationLink(destination: NotificationSettingsView()) {
                            HStack {
                                Image(systemName: "bell.badge")
                                    .foregroundColor(.orange)
                                Text("Notification Settings")
                            }
                        }
                    }
                }
                
                // Location Services Section
                Section("Location Services") {
                    Toggle(isOn: $enableLocationTracking) {
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.green)
                            Text("Enable Location Tracking")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "location.circle")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("Location Services")
                                .font(.headline)
                            Text(locationStatusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if locationManager.authorizationStatus == .denied {
                            Button("Enable") {
                                locationManager.openSettings()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // Appearance Section
                Section("Appearance") {
                    Picker("Theme", selection: $appTheme) {
                        Text("System").tag("System")
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Analytics & Privacy Section
                Section("Analytics & Privacy") {
                    Toggle(isOn: $enableAnalytics) {
                        HStack {
                            Image(systemName: "chart.bar")
                                .foregroundColor(.blue)
                            Text("Analytics")
                        }
                    }
                    
                    Toggle(isOn: $enableCrashReporting) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Crash Reporting")
                        }
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.purple)
                            Text("Privacy Settings")
                        }
                    }
                }
                
                // Data Management Section
                Section("Data Management") {
                    Button(action: { showingExportData = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.green)
                            Text("Export Data")
                        }
                    }
                    
                    NavigationLink(destination: BackupRestoreView()) {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.blue)
                            Text("Backup & Restore")
                        }
                    }
                    
                    Button(action: { showingDeleteAccount = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Support Section
                Section("Support") {
                    NavigationLink(destination: HelpCenterView()) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                            Text("Help Center")
                        }
                    }
                    
                    NavigationLink(destination: ContactSupportView()) {
                        HStack {
                            Image(systemName: "message")
                                .foregroundColor(.green)
                            Text("Contact Support")
                        }
                    }
                    
                    NavigationLink(destination: FeedbackView()) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                            Text("Send Feedback")
                        }
                    }
                }
                
                // Legal Section
                Section("Legal") {
                    Button(action: { showingPrivacyPolicy = true }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                            Text("Privacy Policy")
                        }
                    }
                    
                    Button(action: { showingTermsOfService = true }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                            Text("Terms of Service")
                        }
                    }
                    
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("About PetPath")
                        }
                    }
                }
                
                // App Version
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            Text("PetPath")
                                .font(.headline)
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportData) {
                ExportDataView()
            }
            .sheet(isPresented: $showingDeleteAccount) {
                DeleteAccountView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
            }
        }
    }
    
    private var locationStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Not requested"
        case .denied, .restricted:
            return "Disabled"
        case .authorizedWhenInUse:
            return "Enabled while using app"
        case .authorizedAlways:
            return "Always enabled"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - Supporting Views

struct BusinessHoursView: View {
    @State private var businessHours: [BusinessHour] = BusinessHour.defaultHours
    
    var body: some View {
        List {
            ForEach($businessHours) { $hour in
                VStack(alignment: .leading) {
                    Text(hour.dayName)
                        .font(.headline)
                    HStack {
                        Text("Open: \(hour.openTime, style: .time)")
                        Spacer()
                        Text("Close: \(hour.closeTime, style: .time)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Business Hours")
    }
}

struct ServiceTypesView: View {
    @State private var serviceTypes: [ServiceType] = ServiceType.allCases
    
    var body: some View {
        List {
            ForEach(serviceTypes, id: \.self) { service in
                HStack {
                    Text(service.rawValue)
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Service Types")
    }
}

struct PricingView: View {
    @State private var pricing: [ServicePricing] = ServicePricing.defaultPricing
    
    var body: some View {
        List {
            ForEach(pricing) { price in
                HStack {
                    Text(price.serviceType.rawValue)
                    Spacer()
                    Text("$\(price.price, specifier: "%.2f")")
                        .fontWeight(.semibold)
                }
            }
        }
        .navigationTitle("Pricing")
    }
}

struct AIPreferencesView: View {
    @AppStorage("aiRouteOptimization") private var aiRouteOptimization = true
    @AppStorage("aiPetRecommendations") private var aiPetRecommendations = true
    @AppStorage("aiDurationPrediction") private var aiDurationPrediction = true
    @AppStorage("aiTimeSuggestions") private var aiTimeSuggestions = true
    
    var body: some View {
        List {
            Section("AI Features") {
                Toggle("Route Optimization", isOn: $aiRouteOptimization)
                Toggle("Pet Care Recommendations", isOn: $aiPetRecommendations)
                Toggle("Duration Prediction", isOn: $aiDurationPrediction)
                Toggle("Time Suggestions", isOn: $aiTimeSuggestions)
            }
        }
        .navigationTitle("AI Preferences")
    }
}

struct NotificationSettingsView: View {
    @AppStorage("notifyAppointments") private var notifyAppointments = true
    @AppStorage("notifyReminders") private var notifyReminders = true
    @AppStorage("notifyUpdates") private var notifyUpdates = true
    @AppStorage("reminderTime") private var reminderTime = 30
    
    var body: some View {
        List {
            Section("Notification Types") {
                Toggle("Appointment Notifications", isOn: $notifyAppointments)
                Toggle("Reminder Notifications", isOn: $notifyReminders)
                Toggle("App Updates", isOn: $notifyUpdates)
            }
            
            Section("Reminder Settings") {
                Picker("Reminder Time", selection: $reminderTime) {
                    Text("15 minutes").tag(15)
                    Text("30 minutes").tag(30)
                    Text("1 hour").tag(60)
                    Text("2 hours").tag(120)
                }
            }
        }
        .navigationTitle("Notifications")
    }
}

struct PrivacySettingsView: View {
    @AppStorage("shareAnalytics") private var shareAnalytics = true
    @AppStorage("shareLocation") private var shareLocation = true
    
    var body: some View {
        List {
            Section("Data Sharing") {
                Toggle("Share Analytics", isOn: $shareAnalytics)
                Toggle("Share Location Data", isOn: $shareLocation)
            }
        }
        .navigationTitle("Privacy")
    }
}

struct BackupRestoreView: View {
    var body: some View {
        List {
            Section("Backup") {
                Button("Create Backup") {
                    // TODO: Implement backup
                }
                Button("Restore from Backup") {
                    // TODO: Implement restore
                }
            }
        }
        .navigationTitle("Backup & Restore")
    }
}

struct HelpCenterView: View {
    var body: some View {
        List {
            Section("Getting Started") {
                NavigationLink("How to add clients", destination: Text("Help content"))
                NavigationLink("How to schedule appointments", destination: Text("Help content"))
                NavigationLink("How to use AI features", destination: Text("Help content"))
            }
            
            Section("Troubleshooting") {
                NavigationLink("Common issues", destination: Text("Help content"))
                NavigationLink("Contact support", destination: Text("Help content"))
            }
        }
        .navigationTitle("Help Center")
    }
}

struct ContactSupportView: View {
    @State private var subject = ""
    @State private var message = ""
    
    var body: some View {
        Form {
            Section("Contact Information") {
                TextField("Subject", text: $subject)
                TextEditor(text: $message)
                    .frame(height: 100)
            }
            
            Section {
                Button("Send Message") {
                    // TODO: Implement send
                }
            }
        }
        .navigationTitle("Contact Support")
    }
}

struct FeedbackView: View {
    @State private var feedback = ""
    @State private var rating = 5
    
    var body: some View {
        Form {
            Section("Rating") {
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                rating = star
                            }
                    }
                }
            }
            
            Section("Feedback") {
                TextEditor(text: $feedback)
                    .frame(height: 100)
            }
            
            Section {
                Button("Submit Feedback") {
                    // TODO: Implement submit
                }
            }
        }
        .navigationTitle("Send Feedback")
    }
}

struct ExportDataView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Export Options") {
                    Button("Export Clients") {
                        // TODO: Implement export
                    }
                    Button("Export Appointments") {
                        // TODO: Implement export
                    }
                    Button("Export All Data") {
                        // TODO: Implement export
                    }
                }
            }
            .navigationTitle("Export Data")
        }
    }
}

struct DeleteAccountView: View {
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Delete Account")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("This action cannot be undone. All your data will be permanently deleted.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Delete Account") {
                    showingConfirmation = true
                }
                .foregroundColor(.red)
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Delete Account")
            .alert("Confirm Deletion", isPresented: $showingConfirmation) {
                Button("Delete", role: .destructive) {
                    // TODO: Implement deletion
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 10) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("PetPath")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Section("About") {
                    Text("PetPath is a comprehensive pet grooming management app designed to streamline your business operations with AI-powered features.")
                }
                
                Section("Features") {
                    Text("• Client & Pet Management")
                    Text("• Appointment Scheduling")
                    Text("• Route Optimization")
                    Text("• AI-Powered Insights")
                    Text("• Analytics & Reporting")
                }
            }
            .navigationTitle("About")
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: July 8, 2025")
                        .foregroundColor(.secondary)
                    
                    Text("Your privacy is important to us. This privacy policy explains how we collect, use, and protect your information.")
                    
                    Text("Information We Collect")
                        .font(.headline)
                    
                    Text("We collect information you provide directly to us, such as when you create an account, add clients, or schedule appointments.")
                    
                    Text("How We Use Your Information")
                        .font(.headline)
                    
                    Text("We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.")
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
        }
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: July 8, 2025")
                        .foregroundColor(.secondary)
                    
                    Text("By using PetPath, you agree to these terms of service.")
                    
                    Text("Acceptance of Terms")
                        .font(.headline)
                    
                    Text("By accessing or using PetPath, you agree to be bound by these terms and all applicable laws and regulations.")
                    
                    Text("Use License")
                        .font(.headline)
                    
                    Text("Permission is granted to temporarily use PetPath for personal or commercial pet grooming business purposes.")
                }
                .padding()
            }
            .navigationTitle("Terms of Service")
        }
    }
}

// MARK: - Supporting Models

struct BusinessHour: Identifiable {
    let id = UUID()
    let dayName: String
    var openTime: Date
    var closeTime: Date
    
    static var defaultHours: [BusinessHour] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            BusinessHour(dayName: "Monday", openTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now, closeTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now),
            BusinessHour(dayName: "Tuesday", openTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now, closeTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now),
            BusinessHour(dayName: "Wednesday", openTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now, closeTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now),
            BusinessHour(dayName: "Thursday", openTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now, closeTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now),
            BusinessHour(dayName: "Friday", openTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now, closeTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now),
            BusinessHour(dayName: "Saturday", openTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now, closeTime: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: now) ?? now),
            BusinessHour(dayName: "Sunday", openTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now) ?? now, closeTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now) ?? now)
        ]
    }
}

struct ServicePricing: Identifiable {
    let id = UUID()
    let serviceType: ServiceType
    let price: Double
    
    static var defaultPricing: [ServicePricing] {
        ServiceType.allCases.map { service in
            ServicePricing(serviceType: service, price: getDefaultPrice(for: service))
        }
    }
    
    private static func getDefaultPrice(for service: ServiceType) -> Double {
        switch service {
        case .grooming: return 75.0
        case .bath: return 45.0
        case .nailTrim: return 25.0
        case .earCleaning: return 20.0
        case .fullService: return 95.0
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LocationManager())
        .environmentObject(ClientManager())
        .environmentObject(AnalyticsManager())
}
