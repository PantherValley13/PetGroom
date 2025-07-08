//
//  ClientsView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct ClientsView: View {
    @State private var clients = Client.sample
    @State private var pets = Pet.sample
    
    var body: some View {
        NavigationView {
            List {
                Section("Clients") {
                    ForEach(clients) { client in
                        NavigationLink(destination: ClientDetailView(client: client)) {
                            ClientRow(client: client)
                        }
                    }
                }
                
                Section("Pets") {
                    ForEach(pets) { pet in
                        NavigationLink(destination: PetDetailView(pet: pet)) {
                            PetRow(pet: pet)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Clients & Pets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct ClientRow: View {
    let client: Client
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(client.name)
                .font(.headline)
            Text(client.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct PetRow: View {
    let pet: Pet
    
    var body: some View {
        HStack {
            Image(systemName: "pawprint.fill")
                .foregroundColor(.orange)
            VStack(alignment: .leading) {
                Text(pet.name)
                    .font(.headline)
                Text(pet.breed)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ClientDetailView: View {
    let client: Client
    
    var body: some View {
        Form {
            Section("Contact Info") {
                Text(client.name)
                Text(client.address)
                Text(client.phone)
            }
        }
        .navigationTitle(client.name)
    }
}

struct PetDetailView: View {
    @State var pet: Pet
    
    var body: some View {
        Form {
            Section("Pet Info") {
                Text(pet.name)
                Text(pet.breed)
            }
            
            Section("Notes") {
                TextEditor(text: $pet.notes)
                    .frame(minHeight: 200)
            }
        }
        .navigationTitle(pet.name)
    }
}
