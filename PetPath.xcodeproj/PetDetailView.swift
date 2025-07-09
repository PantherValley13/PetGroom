import SwiftUI
import PetNotesEditor
import DeepSeekService

struct PetDetailView: View {
    @ObservedObject var pet: Pet
    
    @State private var aiSummary: String? = nil
    @State private var aiLoading = false
    @State private var aiError: String? = nil
    
    var body: some View {
        Form {
            Section("Name") {
                Text(pet.name)
            }
            Section("Species") {
                Text(pet.species)
            }
            Section("Breed") {
                Text(pet.breed)
            }
            Section("Age") {
                Text("\(pet.age)")
            }
            Section("Notes") {
                NavigationLink(destination: PetNotesEditor(pet: $pet.wrappedValue)) {
                    Text("Edit Notes & Behavior Tags")
                }
            }
            Section("AI Behavior Summary") {
                Button(action: {
                    aiLoading = true
                    aiSummary = nil
                    aiError = nil
                    DeepSeekService.shared.summarizePet(pet: pet) { result in
                        DispatchQueue.main.async {
                            aiLoading = false
                            switch result {
                            case .success(let summary):
                                aiSummary = summary
                            case .failure(let error):
                                aiError = error
                            }
                        }
                    }
                }) {
                    HStack {
                        if aiLoading { ProgressView() }
                        Text(aiLoading ? "Contacting AI..." : "Get AI Summary")
                    }
                }
                .disabled(aiLoading)
                if let aiSummary = aiSummary {
                    Text(aiSummary)
                        .font(.body)
                        .padding(4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                if let aiError = aiError {
                    Text("AI Error: \(aiError)")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(pet.name)
    }
}
