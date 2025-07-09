// GamificationService.swift
// Tracks streaks, leaderboards, referral rewards.

import Foundation
import Combine

final class GamificationService: ObservableObject {
    static let shared = GamificationService()

    @Published var clientStreaks: [UUID: Int] = [:] // clientId -> current streak
    @Published var groomerScores: [String: Int] = [:] // groomerId/name -> score
    @Published var referrals: [UUID: Int] = [:] // clientId -> referral count
    @Published var loyaltyRewards: [UUID: Bool] = [:] // clientId -> has streak reward

    // Call this after a successful appointment
    func recordVisit(for clientId: UUID) {
        clientStreaks[clientId, default: 0] += 1
        checkAndRewardLoyalty(for: clientId)
    }
    
    func resetStreak(for clientId: UUID) {
        clientStreaks[clientId] = 0
    }
    
    func recordReferral(from clientId: UUID) {
        referrals[clientId, default: 0] += 1
        if referrals[clientId, default: 0] % 3 == 0 {
            updateGroomerScore(groomer: "referrals", delta: 10)
        }
    }
    
    func updateGroomerScore(groomer: String, delta: Int) {
        groomerScores[groomer, default: 0] += delta
    }
    
    func getTopClients(limit: Int = 5) -> [UUID] {
        return Array(clientStreaks.sorted { $0.value > $1.value }.prefix(limit).map { $0.key })
    }
    
    func getTopGroomers(limit: Int = 5) -> [String] {
        return Array(groomerScores.sorted { $0.value > $1.value }.prefix(limit).map { $0.key })
    }
    
    func checkAndRewardLoyalty(for clientId: UUID) {
        let streak = clientStreaks[clientId, default: 0]
        if streak > 0 && streak % 5 == 0 {
            loyaltyRewards[clientId] = true // Mark as eligible for reward
        }
    }
    
    // Computed properties for dashboard
    var topStreak: Int {
        return clientStreaks.values.max() ?? 0
    }
    
    var topReferrerName: String {
        let topReferrer = referrals.max { $0.value < $1.value }
        return topReferrer?.key.uuidString.prefix(8).description ?? "None"
    }
}
