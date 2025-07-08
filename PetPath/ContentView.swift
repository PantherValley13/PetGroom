import SwiftUI

struct ContentView: View {
    @StateObject var subscriptionManager = SubscriptionManager()
    
    var body: some View {
        if subscriptionManager.isSubscribed {
            MainAppView()
        } else {
            SubscriptionView()
                .environmentObject(subscriptionManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
