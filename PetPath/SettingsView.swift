//
//  SettingsView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
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
}
