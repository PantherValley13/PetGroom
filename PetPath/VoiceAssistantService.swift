// VoiceAssistantService.swift
// Handles Siri/voice assistant triggers for hands-free updates.

import Foundation
import SwiftUI
import Combine

class VoiceAssistantService: ObservableObject {
    static let shared = VoiceAssistantService()
    
    func handleVoiceCommand(_ command: String) -> String {
        // Simple parser for demo; expand as needed
        if command.lowercased().contains("add") && command.lowercased().contains("appointment") {
            return "Appointment added!"
        } else if command.lowercased().contains("reschedule") {
            return "Reschedule initiated. Suggesting options..."
        } else if command.lowercased().contains("cancel") {
            return "Appointment canceled."
        }
        return "Command not recognized."
    }
}
