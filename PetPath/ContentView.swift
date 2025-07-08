import SwiftUI

struct ContentView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        Group {
            if subscriptionManager.isLoading {
                // Show loading screen while checking subscription status
                VStack(spacing: 20) {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("PetPath")
                        .font(.largeTitle.bold())
                    
                    ProgressView("Checking subscription...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                }
            } else if subscriptionManager.isSubscribed {
                MainAppView()
            } else {
                SubscriptionView()
                    .environmentObject(subscriptionManager)
            }
        }
        .onAppear {
            subscriptionManager.checkSubscriptionStatus()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SubscriptionManager())
    }
}
