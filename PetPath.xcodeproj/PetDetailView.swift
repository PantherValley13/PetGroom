import SwiftUI
import PetNotesEditor

struct PetDetailView: View {
    @ObservedObject var pet: Pet
    
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
        }
        .navigationTitle(pet.name)
    }
}
