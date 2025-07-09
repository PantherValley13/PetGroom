import SwiftUI

struct ClientDetailView: View {
    @State private var client: Client
    @State private var clv: Double?
    @State private var hasLoyaltyReward: Bool = false
    
    @EnvironmentObject var analyticsManager: AnalyticsManager
    
    init(client: Client) {
        self._client = State(initialValue: client)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // CLV at top if present
            if let clv = clv {
                Text("Lifetime Value: $\(String(format: "%.2f", clv))")
                    .font(.headline)
            }
            
            // VIP badge
            if client.isVIP {
                Text("VIP")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .foregroundColor(.black)
            }
            
            // Referral info
            if !client.referralCode.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.green)
                    Text("Referral Code: \(client.referralCode)")
                        .font(.subheadline)
                }
            } else if let referredBy = client.referredBy, !referredBy.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill.questionmark")
                        .foregroundColor(.blue)
                    Text("Referred by: \(referredBy)")
                        .font(.subheadline)
                }
            }
            
            // Warning banner if reviewSentiment < 0
            if client.reviewSentiment < 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Warning: Possible dissatisfaction detected")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Current streak and loyalty reward info
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak: \(GamificationService.shared.clientStreaks[client.id] ?? 0)")
                if hasLoyaltyReward {
                    Text("🎉 Loyalty Reward Available!")
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            // Social photos section
            if !client.socialPhotoURLs.isEmpty {
                Text("Social Photos")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(client.socialPhotoURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 80, height: 80)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(8)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            
            // Upload photo button
            Button(action: {
                // Append placeholder URL
                let placeholderURL = "https://example.com/placeholder.jpg"
                client.socialPhotoURLs.append(placeholderURL)
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Upload Social Photo")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
            let calculatedCLV = analyticsManager.calculateCLV(for: client)
            clv = calculatedCLV
            client.clv = calculatedCLV
            hasLoyaltyReward = GamificationService.shared.loyaltyRewards[client.id] == true
        }
    }
}
