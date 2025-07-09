//
//  ClientsView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI
import Combine

struct ClientsView: View {
    @EnvironmentObject var manager: ClientManager
    @State private var showingAddClient = false
    @State private var showingAddPet = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Clients") {
                    ForEach(manager.clients) { client in
                        NavigationLink(destination: ClientDetailView(client: client)) {
                            ClientRow(client: client)
                                .onTapGesture {
                                    // Simulate a local notification for client check-in
                                    print("Notification: Client check-in for \(client.name)")
                                }
                        }
                    }
                }
                
                Section("Pets") {
                    ForEach(manager.pets) { pet in
                        NavigationLink(destination: PetDetailView(pet: pet)) {
                            PetRow(pet: pet)
                                .onTapGesture {
                                    // Simulate a local notification for pet check-in
                                    var notificationMessage = "Pet check-in for \(pet.name)"
                                    if !pet.allergies.isEmpty || !pet.medicalConditions.isEmpty {
                                        var allergyMedicalInfo = [String]()
                                        if !pet.allergies.isEmpty {
                                            allergyMedicalInfo.append("Allergies: \(pet.allergies.joined(separator: ", "))")
                                        }
                                        if !pet.medicalConditions.isEmpty {
                                            allergyMedicalInfo.append("Medical: \(pet.medicalConditions.joined(separator: ", "))")
                                        }
                                        notificationMessage += " - " + allergyMedicalInfo.joined(separator: ", ")
                                    }
                                    print("Notification: \(notificationMessage)")
                                }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showingAddPet = true }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Clients & Pets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddClient = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView()
                    .environmentObject(manager)
            }
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
                    .environmentObject(manager)
            }
        }
    }
}

struct ClientRow: View {
    let client: Client
    @EnvironmentObject var manager: ClientManager
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Text(client.name)
                        .font(.headline)
                    if client.isVIP {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .accessibilityLabel("VIP Client")
                    }
                    if let streak = GamificationService.shared.clientStreaks[client.id], streak > 0 {
                        Text("🔥\(streak)")
                            .font(.caption2)
                            .padding(4)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .accessibilityLabel("Client Streak")
                    }
                    if GamificationService.shared.loyaltyRewards[client.id] == true {
                        Image(systemName: "gift.fill")
                            .foregroundColor(.green)
                            .accessibilityLabel("Loyalty Reward")
                    }
                }
                if client.clv > 0 {
                    Text("CLV: $\(String(format: "%.2f", client.clv))")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                Text(client.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    if !client.referralCode.isEmpty || client.referredBy != nil {
                        Image(systemName: "link")
                            .foregroundColor(.accentColor)
                            .accessibilityLabel("Referral Tracking")
                    }
                }
            }
        }
    }
}

struct PetRow: View {
    let pet: Pet
    
    var hasBehaviorWarning: Bool {
        let summary = pet.personalitySummary.lowercased()
        return summary.contains("anxious") || summary.contains("difficult")
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !pet.lastPhotoURL.isEmpty, let url = URL(string: pet.lastPhotoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "pawprint.fill")
                    .foregroundColor(.orange)
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading) {
                HStack(spacing: 6) {
                    Text(pet.name)
                        .font(.headline)
                    if !pet.allergies.isEmpty || !pet.medicalConditions.isEmpty {
                        Image(systemName: "bandage.fill")
                            .foregroundColor(.red)
                            .accessibilityLabel("Medical Alert")
                    }
                    if hasBehaviorWarning {
                        Text("⚠️")
                            .font(.caption)
                            .padding(4)
                            .background(Color.yellow.opacity(0.8))
                            .clipShape(Circle())
                            .accessibilityLabel("Behavior Warning")
                    }
                }
                if !pet.personalitySummary.isEmpty {
                    Text(pet.personalitySummary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if !pet.breed.isEmpty {
                    Text(pet.breed)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// Note: PetDetailView is defined in PetDetailView.swift
