//
//  LocationPermissionView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Enable Location Services")
                .font(.title2.bold())
            
            Text("PetPath needs access to your location to show your current position and optimize routes to your appointments.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                permissionButton
                
                if locationManager.authorizationStatus == .denied {
                    Button("Open Settings") {
                        locationManager.openSettings()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var permissionButton: some View {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            Button("Allow Location Access") {
                locationManager.requestPermission()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .cornerRadius(10)
            
        case .denied, .restricted:
            VStack(spacing: 8) {
                Text("Location Access Denied")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text("To use map features, please enable location access in Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
        case .authorizedWhenInUse, .authorizedAlways:
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Location Access Granted")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
        @unknown default:
            Button("Request Location Access") {
                locationManager.requestPermission()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .cornerRadius(10)
        }
    }
} 