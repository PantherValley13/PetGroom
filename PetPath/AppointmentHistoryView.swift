import Foundation
import SwiftUI

struct AppointmentHistoryView: View {
    @ObservedObject var routeManager: RouteManager
    
    var sortedAppointments: [Appointment] {
        routeManager.appointments.sorted { $0.time > $1.time }
    }
    
    var body: some View {
        List {
            Section("All Appointments") {
                if sortedAppointments.isEmpty {
                    Text("No appointments found").foregroundColor(.secondary)
                } else {
                    ForEach(sortedAppointments) { appointment in
                        VStack(alignment: .leading) {
                            Text(appointment.clientName)
                                .font(.headline)
                            Text(appointment.petName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Service: \(appointment.serviceType.rawValue)")
                                .font(.caption)
                                .foregroundColor(.orange)
                            HStack {
                                Text(appointment.time, style: .date)
                                Text(appointment.time, style: .time)
                                Text("\(appointment.duration) min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Appointment History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AppointmentHistoryView(routeManager: RouteManager(analyticsManager: AnalyticsManager()))
}
