//
//  Persistence.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation

class Persistence {
    static let shared = Persistence()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func save<T: Codable>(_ value: T, for key: String) {
        if let data = try? JSONEncoder().encode(value) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    func load<T: Codable>(_ type: T.Type, for key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func remove(for key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAll() {
        let keys = ["clients", "pets", "appointments"]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
} 