//
//  SettingsView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            Form {
                Section("Location") {
                    HStack {
                        Image(systemName: "location.circle")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("Location Services")
                                .font(.headline)
                            Text(locationStatusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if locationManager.authorizationStatus == .denied {
                            Button("Enable") {
                                locationManager.openSettings()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                Section("Account") {
                    NavigationLink("Subscription", destination: Text("Subscription Settings"))
                    NavigationLink("Payment Methods", destination: Text("Payment Settings"))
                }
                
                Section("Preferences") {
                    NavigationLink("Notification Settings", destination: Text("Notification Settings"))
                    NavigationLink("Route Preferences", destination: Text("Route Settings"))
                }
                
                Section("Support") {
                    NavigationLink("Help Center", destination: Text("Help Center"))
                    NavigationLink("Contact Support", destination: Text("Contact Form"))
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private var locationStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Not requested"
        case .denied, .restricted:
            return "Disabled"
        case .authorizedWhenInUse:
            return "Enabled while using app"
        case .authorizedAlways:
            return "Always enabled"
        @unknown default:
            return "Unknown"
        }
    }
}
