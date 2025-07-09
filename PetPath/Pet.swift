//
//  Pet.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import Combine
import SwiftUI

final class Pet: ObservableObject, Identifiable, Codable, Hashable {
    static func == (lhs: Pet, rhs: Pet) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: UUID
    @Published var name: String
    @Published var breed: String
    @Published var notes: String
    @Published var temperament: String
    var ownerId: UUID? // Link to Client
    @Published var behaviorTags: [BehaviorTag]
    
    // Enhanced pet information
    var age: Int = 0
    var weight: Double = 0.0
    var color: String = ""
    var microchipNumber: String = ""
    var medicalConditions: [String] = []
    var allergies: [String] = []
    var medications: [String] = []
    var veterinarian: String = ""
    var vetPhone: String = ""
    var photoURL: String = "" // URL to stored photo
    var serviceHistory: [ServiceRecord] = []
    var favoriteTreats: [String] = []
    var groomingPreferences: [String] = []
    var specialNeeds: [String] = []
    var lastGroomingDate: Date?
    var nextGroomingDue: Date?
    
    @Published var personalitySummary: String = ""
    @Published var lastPhotoURL: String = "" // For simple pet social photo
    @Published var aiVisitCount: Int = 0 // For triggering personality summary
    
    enum CodingKeys: String, CodingKey {
        case id, name, breed, notes, temperament, ownerId, behaviorTags, age, weight, color, microchipNumber, medicalConditions, allergies, medications, veterinarian, vetPhone, photoURL, serviceHistory, favoriteTreats, groomingPreferences, specialNeeds, lastGroomingDate, nextGroomingDue, personalitySummary, lastPhotoURL, aiVisitCount
    }
    
    init(id: UUID = UUID(), name: String, breed: String, notes: String, temperament: String, ownerId: UUID? = nil, behaviorTags: [BehaviorTag] = [], age: Int = 0, weight: Double = 0.0, color: String = "", microchipNumber: String = "", medicalConditions: [String] = [], allergies: [String] = [], medications: [String] = [], veterinarian: String = "", vetPhone: String = "", photoURL: String = "", serviceHistory: [ServiceRecord] = [], favoriteTreats: [String] = [], groomingPreferences: [String] = [], specialNeeds: [String] = [], lastGroomingDate: Date? = nil, nextGroomingDue: Date? = nil, personalitySummary: String = "", lastPhotoURL: String = "", aiVisitCount: Int = 0) {
        self.id = id
        self.name = name
        self.breed = breed
        self.notes = notes
        self.temperament = temperament
        self.ownerId = ownerId
        self.behaviorTags = behaviorTags
        self.age = age
        self.weight = weight
        self.color = color
        self.microchipNumber = microchipNumber
        self.medicalConditions = medicalConditions
        self.allergies = allergies
        self.medications = medications
        self.veterinarian = veterinarian
        self.vetPhone = vetPhone
        self.photoURL = photoURL
        self.serviceHistory = serviceHistory
        self.favoriteTreats = favoriteTreats
        self.groomingPreferences = groomingPreferences
        self.specialNeeds = specialNeeds
        self.lastGroomingDate = lastGroomingDate
        self.nextGroomingDue = nextGroomingDue
        self.personalitySummary = personalitySummary
        self.lastPhotoURL = lastPhotoURL
        self.aiVisitCount = aiVisitCount
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        breed = try container.decode(String.self, forKey: .breed)
        notes = try container.decode(String.self, forKey: .notes)
        temperament = try container.decode(String.self, forKey: .temperament)
        ownerId = try container.decodeIfPresent(UUID.self, forKey: .ownerId)
        behaviorTags = try container.decodeIfPresent([BehaviorTag].self, forKey: .behaviorTags) ?? []
        age = try container.decodeIfPresent(Int.self, forKey: .age) ?? 0
        weight = try container.decodeIfPresent(Double.self, forKey: .weight) ?? 0.0
        color = try container.decodeIfPresent(String.self, forKey: .color) ?? ""
        microchipNumber = try container.decodeIfPresent(String.self, forKey: .microchipNumber) ?? ""
        medicalConditions = try container.decodeIfPresent([String].self, forKey: .medicalConditions) ?? []
        allergies = try container.decodeIfPresent([String].self, forKey: .allergies) ?? []
        medications = try container.decodeIfPresent([String].self, forKey: .medications) ?? []
        veterinarian = try container.decodeIfPresent(String.self, forKey: .veterinarian) ?? ""
        vetPhone = try container.decodeIfPresent(String.self, forKey: .vetPhone) ?? ""
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL) ?? ""
        serviceHistory = try container.decodeIfPresent([ServiceRecord].self, forKey: .serviceHistory) ?? []
        favoriteTreats = try container.decodeIfPresent([String].self, forKey: .favoriteTreats) ?? []
        groomingPreferences = try container.decodeIfPresent([String].self, forKey: .groomingPreferences) ?? []
        specialNeeds = try container.decodeIfPresent([String].self, forKey: .specialNeeds) ?? []
        lastGroomingDate = try container.decodeIfPresent(Date.self, forKey: .lastGroomingDate)
        nextGroomingDue = try container.decodeIfPresent(Date.self, forKey: .nextGroomingDue)
        personalitySummary = try container.decodeIfPresent(String.self, forKey: .personalitySummary) ?? ""
        lastPhotoURL = try container.decodeIfPresent(String.self, forKey: .lastPhotoURL) ?? ""
        aiVisitCount = try container.decodeIfPresent(Int.self, forKey: .aiVisitCount) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(breed, forKey: .breed)
        try container.encode(notes, forKey: .notes)
        try container.encode(temperament, forKey: .temperament)
        try container.encodeIfPresent(ownerId, forKey: .ownerId)
        try container.encode(behaviorTags, forKey: .behaviorTags)
        try container.encode(age, forKey: .age)
        try container.encode(weight, forKey: .weight)
        try container.encode(color, forKey: .color)
        try container.encode(microchipNumber, forKey: .microchipNumber)
        try container.encode(medicalConditions, forKey: .medicalConditions)
        try container.encode(allergies, forKey: .allergies)
        try container.encode(medications, forKey: .medications)
        try container.encode(veterinarian, forKey: .veterinarian)
        try container.encode(vetPhone, forKey: .vetPhone)
        try container.encode(photoURL, forKey: .photoURL)
        try container.encode(serviceHistory, forKey: .serviceHistory)
        try container.encode(favoriteTreats, forKey: .favoriteTreats)
        try container.encode(groomingPreferences, forKey: .groomingPreferences)
        try container.encode(specialNeeds, forKey: .specialNeeds)
        try container.encodeIfPresent(lastGroomingDate, forKey: .lastGroomingDate)
        try container.encodeIfPresent(nextGroomingDue, forKey: .nextGroomingDue)
        try container.encode(personalitySummary, forKey: .personalitySummary)
        try container.encode(lastPhotoURL, forKey: .lastPhotoURL)
        try container.encode(aiVisitCount, forKey: .aiVisitCount)
    }
    
    // Add service record to history
    func addServiceRecord(_ record: ServiceRecord) {
        serviceHistory.append(record)
        lastGroomingDate = record.date
        nextGroomingDue = Calendar.current.date(byAdding: .month, value: record.recommendedNextVisit, to: record.date)
    }
    
    func incrementVisitCount() {
        aiVisitCount += 1
    }
    
    static var sample: [Pet] {
        [
            Pet(
                name: "Max", 
                breed: "Golden Retriever", 
                notes: "Likes belly rubs", 
                temperament: "Friendly", 
                behaviorTags: [BehaviorTag(label: "Loves Belly Rubs", isActive: true), BehaviorTag(label: "Playful")],
                age: 3,
                weight: 65.0,
                color: "Golden",
                microchipNumber: "123456789",
                medicalConditions: ["Hip dysplasia"],
                allergies: ["Chicken"],
                medications: ["Joint supplement"],
                veterinarian: "Dr. Smith",
                vetPhone: "555-1111",
                favoriteTreats: ["Peanut butter", "Carrots"],
                groomingPreferences: ["Short cut", "No bow"],
                specialNeeds: ["Gentle handling due to hip issues"],
                lastGroomingDate: Date().addingTimeInterval(-86400 * 30),
                nextGroomingDue: Date().addingTimeInterval(86400 * 30),
                personalitySummary: "Max is a friendly and playful golden retriever who loves belly rubs.",
                lastPhotoURL: "https://example.com/photos/max_last.jpg"
            ),
            Pet(
                name: "Bella", 
                breed: "Poodle", 
                notes: "Nervous with clippers", 
                temperament: "Anxious", 
                behaviorTags: [BehaviorTag(label: "Nervous", isActive: true), BehaviorTag(label: "Shy")],
                age: 5,
                weight: 45.0,
                color: "White",
                microchipNumber: "987654321",
                medicalConditions: ["Anxiety"],
                allergies: ["Wheat"],
                medications: ["Calming supplement"],
                veterinarian: "Dr. Johnson",
                vetPhone: "555-2222",
                favoriteTreats: ["Cheese", "Apples"],
                groomingPreferences: ["Puppy cut", "Pink bow"],
                specialNeeds: ["Extra time for acclimation"],
                lastGroomingDate: Date().addingTimeInterval(-86400 * 21),
                nextGroomingDue: Date().addingTimeInterval(86400 * 21),
                personalitySummary: "Bella is an anxious poodle who prefers calm and gentle grooming sessions.",
                lastPhotoURL: "https://example.com/photos/bella_last.jpg"
            ),
            Pet(
                name: "Charlie", 
                breed: "Labrador", 
                notes: "Loves water", 
                temperament: "Playful", 
                behaviorTags: [BehaviorTag(label: "Loves Water", isActive: true)],
                age: 2,
                weight: 70.0,
                color: "Black",
                microchipNumber: "456789123",
                medicalConditions: [],
                allergies: [],
                medications: [],
                veterinarian: "Dr. Brown",
                vetPhone: "555-3333",
                favoriteTreats: ["Tennis balls", "Ice cubes"],
                groomingPreferences: ["Natural look", "No accessories"],
                specialNeeds: ["Loves water play during bath"],
                lastGroomingDate: Date().addingTimeInterval(-86400 * 14),
                nextGroomingDue: Date().addingTimeInterval(86400 * 28),
                personalitySummary: "Charlie is a playful labrador who enjoys water and fun grooming styles.",
                lastPhotoURL: "https://example.com/photos/charlie_last.jpg"
            )
        ]
    }
}

// Service record for tracking history
struct ServiceRecord: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let serviceType: ServiceType
    let duration: Int
    let price: Double
    let notes: String
    let groomer: String
    let recommendedNextVisit: Int // months
    let upcharges: [String]
    let beforePhotos: [String] // URLs
    let afterPhotos: [String] // URLs
    
    init(date: Date, serviceType: ServiceType, duration: Int, price: Double, notes: String, groomer: String, recommendedNextVisit: Int = 1, upcharges: [String] = [], beforePhotos: [String] = [], afterPhotos: [String] = []) {
        self.date = date
        self.serviceType = serviceType
        self.duration = duration
        self.price = price
        self.notes = notes
        self.groomer = groomer
        self.recommendedNextVisit = recommendedNextVisit
        self.upcharges = upcharges
        self.beforePhotos = beforePhotos
        self.afterPhotos = afterPhotos
    }
}
