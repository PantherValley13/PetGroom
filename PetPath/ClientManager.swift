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
    @Published var pets: [Pet] = Pet.sample
    
    func addClient(_ client: Client) {
        clients.append(client)
    }
    
    func addPet(_ pet: Pet, to client: Client) {
        pets.append(pet)
    }
    
    func saveNotes(_ notes: String, for pet: Pet) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index].notes = notes
        }
    }
} 