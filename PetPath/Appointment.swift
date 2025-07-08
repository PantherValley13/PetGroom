//
//  Appointment.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import CoreLocation

// Codable wrapper for CLLocationCoordinate2D
struct CodableLocationCoordinate2D: Codable {
    let latitude: Double
    let longitude: Double
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Appointment: Identifiable, Codable {
    let id = UUID()
    var client: Client
    var pet: Pet
    var time: Date
    var duration: Int
    private var _location: CodableLocationCoordinate2D?
    
    // Computed property for convenience
    var location: CLLocationCoordinate2D? {
        get { _location?.coordinate }
        set { _location = newValue.map(CodableLocationCoordinate2D.init) }
    }
    
    // Computed properties for backward compatibility
    var clientName: String {
        client.name
    }
    
    var petName: String {
        pet.name
    }
    
    init(client: Client, pet: Pet, time: Date, duration: Int, location: CLLocationCoordinate2D? = nil) {
        self.id = UUID()
        self.client = client
        self.pet = pet
        self.time = time
        self.duration = duration
        self._location = location.map(CodableLocationCoordinate2D.init)
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
