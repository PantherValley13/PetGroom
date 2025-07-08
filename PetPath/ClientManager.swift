//
//  ClientManager.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

class ClientManager: ObservableObject {
    @Published var clients: [Client] = []
    @Published var pets: [Pet] = []
    
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
    }
    
    func addPet(_ pet: Pet, to client: Client) {
        var newPet = pet
        newPet.ownerId = client.id
        pets.append(newPet)
        saveData()
    }
    
    func saveNotes(_ notes: String, for pet: Pet) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index].notes = notes
            saveData()
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
} 