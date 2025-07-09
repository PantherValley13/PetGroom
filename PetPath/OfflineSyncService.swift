// OfflineSyncService.swift
// Manages offline-first data, syncing, and emergency info.

import Foundation
import Combine

class OfflineSyncService: ObservableObject {
    static let shared = OfflineSyncService()
    
    // Offline cache for appointments, clients, pets (UUID keys for uniqueness)
    @Published var pendingChanges: [String: Any] = [:]
    @Published var lastSync: Date? = nil
    @Published var isOnline: Bool = true
    
    func queueChange(key: String, value: Any) {
        pendingChanges[key] = value
    }
    
    func syncIfNeeded() {
        // Simulate background sync; replace with real sync logic
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // ...Sync logic here...
            DispatchQueue.main.async {
                self.pendingChanges.removeAll()
                self.lastSync = Date()
                self.isOnline = true
                NotificationCenter.default.post(name: Notification.Name("SyncComplete"), object: nil)
            }
        }
    }
    
    // Emergency info cache (for offline access)
    func getEmergencyInfo(for petId: UUID, pets: [Pet]) -> String? {
        return pets.first(where: { $0.id == petId })?.medicalConditions.joined(separator: ", ")
    }
    
    func saveEmergencyInfo(for pets: [Pet]) {
        // Save a local snapshot (simulate persistent cache)
        // ...simulate with: UserDefaults.standard.set(...)
        let infoDict = pets.reduce(into: [String: String]()) { dict, pet in
            dict[pet.id.uuidString] = pet.medicalConditions.joined(separator: ", ")
        }
        UserDefaults.standard.set(infoDict, forKey: "EmergencyPetInfo")
    }
    
    func loadEmergencyInfo() -> [String: String] {
        return UserDefaults.standard.dictionary(forKey: "EmergencyPetInfo") as? [String: String] ?? [:]
    }
}
