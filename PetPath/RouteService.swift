//
//  RouteService.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import Combine



class RouteService: ObservableObject {
    @Published var appointments: [Appointment] = []
    @Published var optimizedRoute: [Appointment] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        appointments = Appointment.sample
        optimizedRoute = appointments
    }
    
    func optimizeRoute() {
        // Simple sorting for now
        optimizedRoute = appointments.sorted(by: { $0.time < $1.time })
    }
}
