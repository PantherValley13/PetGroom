//
//  MainAppView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct MainAppView: View {
    @StateObject var clientManager = ClientManager()
    
    var body: some View {
        TabView {
            RouteView()
                .tabItem {
                    Label("Route", systemImage: "map")
                }
            
            ClientsView()
                .tabItem {
                    Label("Clients", systemImage: "person.2")
                }
                .environmentObject(clientManager)
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.orange)
    }
}
