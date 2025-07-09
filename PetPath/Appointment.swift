//
//  Appointment.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

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
    
    enum CodingKeys: String, CodingKey {
        case id, client, pet, time, duration, serviceType, _location
    }
}

// MARK: - Codable Implementation
extension Appointment {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        client = try container.decode(Client.self, forKey: .client)
        pet = try container.decode(Pet.self, forKey: .pet)
        time = try container.decode(Date.self, forKey: .time)
        duration = try container.decode(Int.self, forKey: .duration)
        serviceType = try container.decode(ServiceType.self, forKey: .serviceType)
        _location = try container.decodeIfPresent(CodableLocationCoordinate2D.self, forKey: ._location)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(client, forKey: .client)
        try container.encode(pet, forKey: .pet)
        try container.encode(time, forKey: .time)
        try container.encode(duration, forKey: .duration)
        try container.encode(serviceType, forKey: .serviceType)
        try container.encodeIfPresent(_location, forKey: ._location)
    }
}

// Sample data for preview/testing
extension Appointment {
    init(client: Client, pet: Pet, time: Date, duration: Int, serviceType: ServiceType, location: CLLocationCoordinate2D? = nil, id: UUID = UUID()) {
        self.id = id
        self.client = client
        self.pet = pet
        self.time = time
        self.duration = duration
        self.serviceType = serviceType
        self._location = location.map(CodableLocationCoordinate2D.init)
    }
    
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
            Appointment(client: client1, pet: pet1, time: calendar.date(byAdding: .hour, value: 1, to: now) ?? now, duration: 60, serviceType: ServiceType.grooming),
            Appointment(client: client2, pet: pet2, time: calendar.date(byAdding: .hour, value: 3, to: now) ?? now, duration: 45, serviceType: ServiceType.bath),
            Appointment(client: client3, pet: pet3, time: calendar.date(byAdding: .hour, value: 5, to: now) ?? now, duration: 30, serviceType: ServiceType.nailTrim)
        ]
    }
}

