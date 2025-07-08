# RevenueCat Integration Setup Guide

## 1. Add RevenueCat via Swift Package Manager

1. Open your project in Xcode
2. Go to **File > Add Package Dependencies**
3. Enter the RevenueCat URL: `https://github.com/RevenueCat/purchases-ios`
4. Select the latest version and add to your target

## 2. Configure RevenueCat Dashboard

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create a new app
3. Add your iOS app with Bundle ID: `com.yourcompany.petpath`
4. Create a product with identifier: `pro_monthly`
5. Set up your entitlement: `pro`
6. Copy your API key

## 3. Update API Key

Replace the placeholder API key in these files:

**AppDelegate.swift:**

```swift
Purchases.configure(withAPIKey: "YOUR_ACTUAL_API_KEY_HERE")
```

## 4. Uncomment RevenueCat Code

In **SubscriptionManager.swift**, uncomment the RevenueCat imports and implementation:

1. Uncomment: `import RevenueCat`
2. Remove the mock struct definitions
3. Uncomment all the RevenueCat implementation code
4. Remove the mock implementations

## 5. Set up App Store Connect

1. Create your in-app purchase product in App Store Connect
2. Product ID should match: `pro_monthly`
3. Set price to $29.99/month
4. Configure free trial period (7 days)

## 6. Test Integration

### Sandbox Testing:

1. Create sandbox test accounts in App Store Connect
2. Sign out of App Store on device
3. Test purchase flow with sandbox account

### StoreKit Configuration (iOS 14+):

1. Create StoreKit configuration file in Xcode
2. Add your subscription product
3. Test locally without sandbox

## 7. Production Checklist

- [ ] Replace test API key with production key
- [ ] Set Purchases.logLevel to .info or .error
- [ ] Test restore purchases
- [ ] Test subscription status checks
- [ ] Add proper error handling UI
- [ ] Implement receipts validation

## 8. Required Capabilities

Make sure your app has these capabilities enabled:

- In-App Purchase
- Push Notifications (for subscription status updates)

## Example Implementation

Once RevenueCat is added, your SubscriptionManager will look like:

```swift
import RevenueCat

class SubscriptionManager: ObservableObject {
    @Published var isSubscribed = false
    @Published var isLoading = false
    @Published var currentPackages: [Package] = []

    init() {
        checkSubscriptionStatus()
    }

    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] info, error in
            DispatchQueue.main.async {
                self?.isSubscribed = info?.entitlements["pro"]?.isActive == true
            }
        }
    }

    // ... rest of implementation
}
```

## Support

For RevenueCat specific issues, check:

- [RevenueCat Documentation](https://docs.revenuecat.com)
- [RevenueCat Community](https://community.revenuecat.com)
