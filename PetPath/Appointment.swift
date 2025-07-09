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

enum ServiceType: String, Codable, CaseIterable {
    case grooming = "Grooming"
    case bath = "Bath"
    case nailTrim = "Nail Trim"
    case earCleaning = "Ear Cleaning"
    case fullService = "Full Service"
}

struct Appointment: Identifiable, Codable {
    let id: UUID
    var client: Client
    var pet: Pet
    var time: Date
    var duration: Int
    var serviceType: ServiceType
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
    
    init(client: Client, pet: Pet, time: Date, duration: Int, serviceType: ServiceType, location: CLLocationCoordinate2D? = nil, id: UUID = UUID()) {
        self.id = id
        self.client = client
        self.pet = pet
        self.time = time
        self.duration = duration
        self.serviceType = serviceType
        self._location = location.map(CodableLocationCoordinate2D.init)
    }
    
    // Sample data for preview/testing
    static var sample: [Appointment] {
        let client1 = Client(name: "Sarah Johnson", address: "123 Main St", phone: "555-1234")
        let client2 = Client(name: "Michael Chen", address: "456 Oak Ave", phone: "555-5678")
        let client3 = Client(name: "Emily Rodriguez", address: "789 Pine Rd", phone: "555-9012")
        
        let pet1 = Pet(name: "Max", breed: "Golden Retriever", notes: "Very friendly and well-behaved", temperament: "Friendly", ownerId: client1.id)
        let pet2 = Pet(name: "Bella", breed: "Persian Cat", notes: "Loves being brushed", temperament: "Calm", ownerId: client2.id)
        let pet3 = Pet(name: "Charlie", breed: "Labrador", notes: "Needs extra attention during nail trims", temperament: "Energetic", ownerId: client3.id)
        
        let now = Date()
        let calendar = Calendar.current
        
        return [
            Appointment(client: client1, pet: pet1, time: calendar.date(byAdding: .hour, value: 1, to: now) ?? now, duration: 60, serviceType: .grooming),
            Appointment(client: client2, pet: pet2, time: calendar.date(byAdding: .hour, value: 3, to: now) ?? now, duration: 45, serviceType: .bath),
            Appointment(client: client3, pet: pet3, time: calendar.date(byAdding: .hour, value: 5, to: now) ?? now, duration: 30, serviceType: .nailTrim)
        ]
    }
}
