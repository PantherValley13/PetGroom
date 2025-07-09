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
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        TabView {
            RouteView()
                .tabItem {
                    Label("Route", systemImage: "map")
                }
                .environmentObject(clientManager)
                .environmentObject(analyticsManager)
                .environmentObject(locationManager)
            
            ClientsView()
                .tabItem {
                    Label("Clients", systemImage: "person.2")
                }
                .environmentObject(clientManager)
                .environmentObject(analyticsManager)
            
            AnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .environmentObject(analyticsManager)
            
            AIFeaturesTestView()
                .tabItem {
                    Label("AI Test", systemImage: "brain.head.profile")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .environmentObject(locationManager)
        }
        .accentColor(.orange)
    }
}

