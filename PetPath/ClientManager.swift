//
//  ClientManager.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI
import Combine

class ClientManager: ObservableObject {
    @Published var clients: [Client] = []
    @Published var pets: [Pet] = []
    
    private let gamificationService = GamificationService.shared
    private let offlineSyncService = OfflineSyncService.shared
    
    init() {
        loadData()
    }
    
    private func loadData() {
        // Load saved data first
        if let savedClients: [Client] = Persistence.shared.load([Client].self, for: "clients") {
            clients = savedClients
        }
        
        if let savedPets: [Pet] = Persistence.shared.load([Pet].self, for: "pets") {
            pets = savedPets
        }
        
        // If no saved data, load sample data
        if clients.isEmpty {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        clients = Client.sample
        
        // Associate sample pets with sample clients
        var samplePets = Pet.sample
        if clients.count >= 3 {
            samplePets[0].ownerId = clients[0].id // Max -> Sarah Johnson
            samplePets[1].ownerId = clients[1].id // Bella -> Michael Chen
            samplePets[2].ownerId = clients[2].id // Charlie -> Emily Rodriguez
        }
        pets = samplePets
        
        // Save the sample data
        saveData()
    }
    
    private func saveData() {
        Persistence.shared.save(clients, for: "clients")
        Persistence.shared.save(pets, for: "pets")
    }
    
    func addClient(_ client: Client) {
        clients.append(client)
        saveData()
        offlineSyncService.queueChange(key: "clients", value: clients)
    }
    
    func addPet(_ pet: Pet, to client: Client) {
        var newPet = pet
        newPet.ownerId = client.id
        newPet.aiVisitCount += 1
        pets.append(newPet)
        saveData()
        offlineSyncService.queueChange(key: "pets", value: pets)
        
        if newPet.aiVisitCount >= 3 {
            Task {
                let summary = await AIService().generatePetSummary(pet: newPet)
                if let index = self.pets.firstIndex(where: { $0.id == newPet.id }) {
                    self.pets[index].personalitySummary = summary
                    saveData()
                }
            }
        }
    }
    
    public func addPet(_ pet: Pet) {
        var newPet = pet
        newPet.aiVisitCount += 1
        pets.append(newPet)
        saveData()
        offlineSyncService.queueChange(key: "pets", value: pets)
        
        if newPet.aiVisitCount >= 3 {
            Task {
                let summary = await AIService().generatePetSummary(pet: newPet)
                if let index = self.pets.firstIndex(where: { $0.id == newPet.id }) {
                    self.pets[index].personalitySummary = summary
                    saveData()
                }
            }
        }
    }
    
    func saveNotes(_ notes: String, for pet: Pet) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index].notes = notes
            saveData()
            
            if pets[index].aiVisitCount >= 3 {
                Task {
                    let summary = await AIService().generatePetSummary(pet: pets[index])
                    if let idx = self.pets.firstIndex(where: { $0.id == pets[index].id }) {
                        self.pets[idx].personalitySummary = summary
                        saveData()
                    }
                }
            }
        }
    }
    
    func getPets(for client: Client) -> [Pet] {
        return pets.filter { $0.ownerId == client.id }
    }
    
    func deleteClient(_ client: Client) {
        clients.removeAll { $0.id == client.id }
        // Also remove associated pets
        pets.removeAll { $0.ownerId == client.id }
        saveData()
    }
    
    func deletePet(_ pet: Pet) {
        pets.removeAll { $0.id == pet.id }
        saveData()
    }
    
    func recordReferral(for clientId: UUID) {
        gamificationService.recordReferral(from: clientId)
    }
} 
