import SwiftUI
import AIRouteOptimizer

class RouteViewModel: ObservableObject {
    @Published var appointments: [Appointment] = []
    @Published var optimizedRoute: [Appointment] = []
    
    private let aiRouteOptimizer = AIRouteOptimizer()
    
    func optimizeRoute() {
        aiRouteOptimizer.optimize(appointments: appointments) { [weak self] optimized in
            DispatchQueue.main.async {
                self?.optimizedRoute = optimized
            }
        }
    }
    
    // Other existing methods and properties
}
