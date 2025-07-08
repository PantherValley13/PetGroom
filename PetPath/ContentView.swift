import SwiftUI

struct ContentView: View {
    @State private var isSubscribed = false
    
    var body: some View {
        if isSubscribed {
            MainAppView()
        } else {
            SubscriptionView(isSubscribed: $isSubscribed)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
