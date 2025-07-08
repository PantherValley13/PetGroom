//
//  AddAppointmentView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct AddAppointmentView: View {
    @EnvironmentObject var routeManager: RouteManager
    @EnvironmentObject var clientManager: ClientManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedClient: Client?
    @State private var selectedPet: Pet?
    @State private var date = Date()
    @State private var duration = 60
    
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
                        .disabled(availablePets.isEmpty)
                    }
                }
                
                Section("Appointment Details") {
                    DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    Stepper("Duration: \(duration) minutes", value: $duration, in: 15...120, step: 15)
                }
                
                Section {
                    Button("Save Appointment") {
                        if let client = selectedClient, let pet = selectedPet {
                            let appointment = Appointment(
                                client: client,
                                pet: pet,
                                time: date,
                                duration: duration
                            )
                            routeManager.addAppointment(appointment)
                            dismiss()
                        }
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
            }
        }
    }
} 