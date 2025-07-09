//
//  AddAppointmentView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct AddAppointmentView: View {
    let routeManager: RouteManager
    @EnvironmentObject var clientManager: ClientManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedClient: Client?
    @State private var selectedPet: Pet?
    @State private var date = Date()
    @State private var duration = 60
    @State private var selectedServiceType: ServiceType = .grooming
    @State private var showingAISuggestions = false
    @State private var aiSuggestedDuration: Int?
    @State private var aiSuggestedTimes: [Date] = []
    @State private var isLoadingAI = false
    
    private var availablePets: [Pet] {
        guard let client = selectedClient else { return [] }
        return clientManager.pets.filter { $0.ownerId == client.id }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Client & Pet") {
                    Picker("Client", selection: $selectedClient) {
                        Text("Select Client").tag(nil as Client?)
                        ForEach(clientManager.clients, id: \.id) { client in
                            Text(client.name).tag(client as Client?)
                        }
                    }
                    .onChange(of: selectedClient) { _, _ in
                        selectedPet = nil // Reset pet selection when client changes
                    }
                    
                    if let client = selectedClient {
                        Picker("Pet", selection: $selectedPet) {
                            Text("Select Pet").tag(nil as Pet?)
                            ForEach(availablePets, id: \.id) { pet in
                                Text(pet.name).tag(pet as Pet?)
                            }
                        }
                        .onChange(of: selectedPet) { _, newPet in
                            if let pet = newPet {
                                getAISuggestions(for: pet)
                            }
                        }
                    }
                }
                
                Section("Service Details") {
                    Picker("Service Type", selection: $selectedServiceType) {
                        ForEach(ServiceType.allCases, id: \.self) { serviceType in
                            Text(serviceType.rawValue).tag(serviceType)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(duration) minutes")
                    }
                    
                    if let aiSuggestedDuration = aiSuggestedDuration {
                        HStack {
                            Text("AI Suggested")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(aiSuggestedDuration) minutes")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section("Date & Time") {
                    DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    if !aiSuggestedTimes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI Suggested Times")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            ForEach(aiSuggestedTimes, id: \.self) { suggestedTime in
                                Button(action: {
                                    date = suggestedTime
                                }) {
                                    HStack {
                                        Text(suggestedTime, style: .time)
                                        Text(suggestedTime, style: .date)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Image(systemName: "clock")
                                            .foregroundColor(.orange)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                if isLoadingAI {
                    Section {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Getting AI suggestions...")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button("Save Appointment") {
                        saveAppointment()
                    }
                    .disabled(selectedClient == nil || selectedPet == nil)
                }
            }
            .navigationTitle("New Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("AI Help") {
                        showingAISuggestions = true
                    }
                    .disabled(selectedPet == nil)
                }
            }
            .sheet(isPresented: $showingAISuggestions) {
                if let pet = selectedPet {
                    AISuggestionsView(pet: pet, serviceType: selectedServiceType)
                }
            }
        }
    }
    
    private func getAISuggestions(for pet: Pet) {
        isLoadingAI = true
        
        Task {
            // Get AI suggestions for duration and optimal times
            let suggestedDuration = await routeManager.predictAppointmentDuration(for: pet, serviceType: selectedServiceType)
            let suggestedTimes = await routeManager.suggestOptimalTimes(for: selectedClient ?? Client(name: "", address: "", phone: ""))
            
            await MainActor.run {
                aiSuggestedDuration = suggestedDuration
                aiSuggestedTimes = suggestedTimes
                isLoadingAI = false
            }
        }
    }
    
    private func saveAppointment() {
        guard let client = selectedClient, let pet = selectedPet else { return }
        
        let appointment = Appointment(
            client: client,
            pet: pet,
            time: date,
            duration: duration,
            serviceType: selectedServiceType
        )
        
        routeManager.addAppointment(appointment)
        dismiss()
    }
}

struct AISuggestionsView: View {
    let pet: Pet
    let serviceType: ServiceType
    @Environment(\.dismiss) var dismiss
    @State private var petSummary: String = ""
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if isLoading {
                        HStack {
                            ProgressView()
                            Text("Generating AI insights...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Pet Analysis")
                                .font(.title2.bold())
                                .foregroundColor(.orange)
                            
                            Text(petSummary)
                                .font(.body)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("AI Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadPetSummary()
        }
    }
    
    private func loadPetSummary() {
        Task {
            let summary = await AIService().generatePetSummary(pet: pet)
            await MainActor.run {
                petSummary = summary
                isLoading = false
            }
        }
    }
}
