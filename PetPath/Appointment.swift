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
    var clientName: String
    var petName: String
    var time: Date
    var duration: Int
    var location: CLLocationCoordinate2D?
    
    static var sample: [Appointment] {
        [
            Appointment(
                clientName: "Sarah Johnson",
                petName: "Max",
                time: Date().addingTimeInterval(3600 * 2),
                duration: 60
            ),
            Appointment(
                clientName: "Michael Chen",
                petName: "Bella",
                time: Date().addingTimeInterval(3600 * 4),
                duration: 45
            )
        ]
    }
}
