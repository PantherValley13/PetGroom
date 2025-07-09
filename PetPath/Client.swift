//
//  Client.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation

struct Client: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var address: String
    var phone: String
    var email: String?
    
    static var sample: [Client] {
        [
            Client(name: "Sarah Johnson", address: "123 Main St", phone: "555-1234"),
            Client(name: "Michael Chen", address: "456 Oak Ave", phone: "555-5678"),
            Client(name: "Emily Rodriguez", address: "789 Pine Rd", phone: "555-9012")
        ]
    }
}
