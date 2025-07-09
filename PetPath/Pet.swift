//
//  Pet.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import Combine
import SwiftUI

class Pet: ObservableObject, Identifiable, Codable, Hashable {
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
    
    enum CodingKeys: String, CodingKey {
        case id, name, breed, notes, temperament, ownerId, behaviorTags
    }
    
    init(id: UUID = UUID(), name: String, breed: String, notes: String, temperament: String, ownerId: UUID? = nil, behaviorTags: [BehaviorTag] = []) {
        self.id = id
        self.name = name
        self.breed = breed
        self.notes = notes
        self.temperament = temperament
        self.ownerId = ownerId
        self.behaviorTags = behaviorTags
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let breed = try container.decode(String.self, forKey: .breed)
        let notes = try container.decode(String.self, forKey: .notes)
        let temperament = try container.decode(String.self, forKey: .temperament)
        let ownerId = try container.decodeIfPresent(UUID.self, forKey: .ownerId)
        let behaviorTags = try container.decodeIfPresent([BehaviorTag].self, forKey: .behaviorTags) ?? []
        self.init(id: id, name: name, breed: breed, notes: notes, temperament: temperament, ownerId: ownerId, behaviorTags: behaviorTags)
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
    }
    
    static var sample: [Pet] {
        [
            Pet(name: "Max", breed: "Golden Retriever", notes: "Likes belly rubs", temperament: "Friendly", behaviorTags: [BehaviorTag(label: "Loves Belly Rubs", isActive: true), BehaviorTag(label: "Playful")]),
            Pet(name: "Bella", breed: "Poodle", notes: "Nervous with clippers", temperament: "Anxious", behaviorTags: [BehaviorTag(label: "Nervous", isActive: true), BehaviorTag(label: "Shy")]),
            Pet(name: "Charlie", breed: "Labrador", notes: "Loves water", temperament: "Playful", behaviorTags: [BehaviorTag(label: "Loves Water", isActive: true)])
        ]
    }
}

