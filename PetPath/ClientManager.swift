//
//  ClientManager.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

class ClientManager: ObservableObject {
    @Published var clients: [Client] = Client.sample
    @Published var pets: [Pet] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Associate sample pets with sample clients
        var samplePets = Pet.sample
        if clients.count >= 3 {
            samplePets[0].ownerId = clients[0].id // Max -> Sarah Johnson
            samplePets[1].ownerId = clients[1].id // Bella -> Michael Chen
            samplePets[2].ownerId = clients[2].id // Charlie -> Emily Rodriguez
        }
        pets = samplePets
    }
    
    func addClient(_ client: Client) {
        clients.append(client)
    }
    
    func addPet(_ pet: Pet, to client: Client) {
        var newPet = pet
        newPet.ownerId = client.id
        pets.append(newPet)
    }
    
    func saveNotes(_ notes: String, for pet: Pet) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index].notes = notes
        }
    }
    
    func getPets(for client: Client) -> [Pet] {
        return pets.filter { $0.ownerId == client.id }
    }
} 