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
    
    // Enhanced business information
    var preferredContactMethod: ContactMethod = .phone
    var notes: String = ""
    var specialInstructions: String = ""
    var emergencyContact: String = ""
    var preferredAppointmentTimes: [String] = []
    var favoriteServices: [ServiceType] = []
    var upchargeItems: [String] = []
    var loyaltyPoints: Int = 0
    var totalSpent: Double = 0.0
    var lastVisit: Date?
    var isVIP: Bool = false

    var clv: Double = 0.0 // Client Lifetime Value
    var referralCode: String = ""
    var referredBy: String? = nil
    var reviewSentiment: Double = 1.0 // +1 = happy, -1 = unhappy
    var lastCheckInDate: Date? = nil
    var socialPhotoURLs: [String] = [] // For pet social network
    
    enum ContactMethod: String, Codable, CaseIterable {
        case phone = "Phone"
        case email = "Email"
        case text = "Text"
    }
    
    static var sample: [Client] {
        [
            Client(
                name: "Sarah Johnson", 
                address: "123 Main St", 
                phone: "555-1234",
                email: "sarah@email.com",
                preferredContactMethod: .email,
                notes: "Prefers morning appointments",
                specialInstructions: "Ring doorbell twice",
                emergencyContact: "555-9999",
                preferredAppointmentTimes: ["9:00 AM", "2:00 PM"],
                favoriteServices: [.grooming, .bath],
                upchargeItems: ["Flea treatment", "Deodorizing spray"],
                loyaltyPoints: 150,
                totalSpent: 450.0,
                lastVisit: Date().addingTimeInterval(-86400 * 7),
                isVIP: true,
                clv: 1200.0,
                referralCode: "SJ2025",
                referredBy: nil,
                reviewSentiment: 0.9,
                lastCheckInDate: Date().addingTimeInterval(-86400 * 2),
                socialPhotoURLs: ["https://petsocial.com/photos/sarah1.jpg", "https://petsocial.com/photos/sarah2.jpg"]
            ),
            Client(
                name: "Michael Chen", 
                address: "456 Oak Ave", 
                phone: "555-5678",
                email: "michael@email.com",
                preferredContactMethod: .text,
                notes: "Very particular about nail length",
                specialInstructions: "Call 10 minutes before arrival",
                emergencyContact: "555-8888",
                preferredAppointmentTimes: ["10:00 AM", "3:00 PM"],
                favoriteServices: [.nailTrim, .earCleaning],
                upchargeItems: ["Nail polish", "Bow tie"],
                loyaltyPoints: 75,
                totalSpent: 280.0,
                lastVisit: Date().addingTimeInterval(-86400 * 14),
                clv: 600.0,
                referralCode: "MC2025",
                referredBy: "SJ2025",
                reviewSentiment: 0.6,
                lastCheckInDate: Date().addingTimeInterval(-86400 * 10),
                socialPhotoURLs: ["https://petsocial.com/photos/michael1.jpg"]
            ),
            Client(
                name: "Emily Rodriguez", 
                address: "789 Pine Rd", 
                phone: "555-9012",
                email: "emily@email.com",
                preferredContactMethod: .phone,
                notes: "New client, very friendly",
                specialInstructions: "Park in driveway",
                emergencyContact: "555-7777",
                preferredAppointmentTimes: ["11:00 AM", "4:00 PM"],
                favoriteServices: [.fullService],
                upchargeItems: ["Conditioning treatment"],
                loyaltyPoints: 25,
                totalSpent: 95.0,
                lastVisit: Date().addingTimeInterval(-86400 * 3),
                clv: 95.0,
                referralCode: "ER2025",
                referredBy: nil,
                reviewSentiment: 1.0,
                lastCheckInDate: Date().addingTimeInterval(-86400),
                socialPhotoURLs: []
            )
        ]
    }
}
