//
//  RouteManager.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

class RouteManager: ObservableObject {
    @Published var appointments: [Appointment] = Appointment.sample
    @Published var optimizedRoute: [Appointment] = []
    
    init() {
        optimizeRoute()
    }
    
    func addAppointment(_ appointment: Appointment) {
        appointments.append(appointment)
        optimizeRoute()
    }
    
    func optimizeRoute() {
        // Simple sorting for now - will add AI later
        optimizedRoute = appointments.sorted(by: { $0.time < $1.time })
    }
} 