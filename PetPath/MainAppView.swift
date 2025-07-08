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
    @StateObject var analyticsManager = AnalyticsManager()
    
    var body: some View {
        TabView {
            RouteView()
                .tabItem {
                    Label("Route", systemImage: "map")
                }
                .environmentObject(clientManager)
                .environmentObject(analyticsManager)
            
            ClientsView()
                .tabItem {
                    Label("Clients", systemImage: "person.2")
                }
                .environmentObject(clientManager)
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .environmentObject(analyticsManager)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.orange)
    }
}
