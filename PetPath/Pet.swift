//
//  Pet.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation

struct Pet: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var breed: String
    var notes: String
    var temperament: String
    var ownerId: UUID? // Link to Client
    
    static var sample: [Pet] {
        [
            Pet(name: "Max", breed: "Golden Retriever", notes: "Likes belly rubs", temperament: "Friendly"),
            Pet(name: "Bella", breed: "Poodle", notes: "Nervous with clippers", temperament: "Anxious"),
            Pet(name: "Charlie", breed: "Labrador", notes: "Loves water", temperament: "Playful")
        ]
    }
}
