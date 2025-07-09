import SwiftUI

struct PetDetailView: View {
    @State private var pet: Pet
    @State private var isRegeneratingSummary = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Personality summary banner
                if !pet.personalitySummary.isEmpty {
                    Text(pet.personalitySummary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Last photo if present
                if !pet.lastPhotoURL.isEmpty, let url = URL(string: pet.lastPhotoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Pet Info with medical alert badge if needed
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Pet Info")
                            .font(.title2)
                            .bold()
                        Spacer()
                        if !pet.medicalConditions.isEmpty || !pet.allergies.isEmpty {
                            Label("Medical Alert", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .padding(6)
                                .background(Color.red.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }
                    
                    Text("Name: \(pet.name)")
                    Text("Age: \(pet.age)")
                    Text("Breed: \(pet.breed)")
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Upload Photo button
                Button(action: {
                    // Simulate photo upload by setting lastPhotoURL to a placeholder image URL
                    pet.lastPhotoURL = "https://placekitten.com/400/400"
                }) {
                    Label("Upload New Photo", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Emergency Info section - always display medicalConditions and allergies
                VStack(alignment: .leading, spacing: 8) {
                    Text("Emergency Info")
                        .font(.title2)
                        .bold()
                    
                    if pet.medicalConditions.isEmpty && pet.allergies.isEmpty {
                        Text("No medical conditions or allergies reported.")
                            .foregroundColor(.secondary)
                    } else {
                        if !pet.medicalConditions.isEmpty {
                            Text("Medical Conditions:")
                                .bold()
                            ForEach(pet.medicalConditions, id: \.self) { condition in
                                Text("• \(condition)")
                            }
                        }
                        if !pet.allergies.isEmpty {
                            Text("Allergies:")
                                .bold()
                                .padding(.top, pet.medicalConditions.isEmpty ? 0 : 8)
                            ForEach(pet.allergies, id: \.self) { allergy in
                                Text("• \(allergy)")
                            }
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // AI personality summary re-generation button if aiVisitCount >= 3
                if pet.aiVisitCount >= 3 {
                    VStack {
                        if isRegeneratingSummary {
                            ProgressView("Regenerating Personality Summary...")
                                .padding()
                        } else {
                            Button(action: {
                                Task {
                                    isRegeneratingSummary = true
                                    let newSummary = await AIService().generatePetSummary(pet: pet)
                                    pet.personalitySummary = newSummary
                                    isRegeneratingSummary = false
                                }
                            }) {
                                Text("Regenerate AI Personality Summary")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Loyalty reward banner if applicable
                if let ownerId = pet.ownerId, GamificationService.shared.loyaltyRewards[ownerId] == true {
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundColor(.yellow)
                        Text("You have a loyalty reward!")
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationTitle(pet.name)
        .onAppear {
            OfflineSyncService.shared.saveEmergencyInfo(for: [pet])
        }
    }
    
    init(pet: Pet) {
        _pet = State(initialValue: pet)
    }
}
