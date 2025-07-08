//
//  AddClientView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import Foundation
import SwiftUI

struct AddClientView: View {
    @EnvironmentObject var manager: ClientManager
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var address = ""
    @State private var phone = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Client Information") {
                    TextField("Name", text: $name)
                    TextField("Address", text: $address)
                    TextField("Phone", text: $phone)
                    TextField("Email (Optional)", text: $email)
                }
                
                Section {
                    Button("Save Client") {
                        let client = Client(name: name, address: address, phone: phone, email: email.isEmpty ? nil : email)
                        manager.addClient(client)
                        dismiss()
                    }
                    .disabled(name.isEmpty || address.isEmpty || phone.isEmpty)
                }
            }
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
} 