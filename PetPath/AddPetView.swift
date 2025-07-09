import SwiftUI

struct AddPetView: View {
    @EnvironmentObject var manager: ClientManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var breed = ""
    @State private var temperament = ""
    @State private var notes = ""
    @State private var selectedOwner: Client?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Owner") {
                    Picker("Client", selection: $selectedOwner) {
                        Text("Select Client").tag(nil as Client?)
                        ForEach(manager.clients, id: \.id) { client in
                            Text(client.name).tag(client as Client?)
                        }
                    }
                }
                
                Section("Pet Info") {
                    TextField("Name", text: $name)
                    TextField("Breed", text: $breed)
                    TextField("Temperament", text: $temperament)
                    TextEditor(text: $notes).frame(minHeight: 60)
                }
                
                Section {
                    Button("Save") {
                        savePet()
                    }
                    .disabled(name.isEmpty || breed.isEmpty || selectedOwner == nil)
                }
            }
            .navigationTitle("Add Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func savePet() {
        guard let owner = selectedOwner else { return }
        let newPet = Pet(
            name: name,
            breed: breed,
            notes: notes,
            temperament: temperament,
            ownerId: owner.id
        )
        manager.addPet(newPet)
        dismiss()
    }
}
