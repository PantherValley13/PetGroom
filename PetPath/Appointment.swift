//
//  Appointment.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import CoreLocation

struct Appointment: Identifiable {
    let id = UUID()
    var client: Client
    var pet: Pet
    var time: Date
    var duration: Int
    var location: CLLocationCoordinate2D?
    
    // Computed properties for backward compatibility
    var clientName: String {
        client.name
    }
    
    var petName: String {
        pet.name
    }
    
    static var sample: [Appointment] {
        let sampleClients = Client.sample
        let samplePets = Pet.sample
        
        return [
            Appointment(
                client: sampleClients[0],
                pet: samplePets[0],
                time: Date().addingTimeInterval(3600 * 2),
                duration: 60
            ),
            Appointment(
                client: sampleClients[1],
                pet: samplePets[1],
                time: Date().addingTimeInterval(3600 * 4),
                duration: 45
            )
        ]
    }
}
