//
//  MapView.swift
//  PetPath
//
//  Created by Darius Church on 7/8/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    var userLocation: CLLocationCoordinate2D?
    var appointments: [Appointment]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        // Set initial region to a default location (will be updated when user location is available)
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        mapView.setRegion(initialRegion, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update user location region
        if let userLocation = userLocation {
            let region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            mapView.setRegion(region, animated: true)
        }
        
        // Remove existing appointment annotations
        let existingAnnotations = mapView.annotations.filter { annotation in
            annotation is AppointmentAnnotation
        }
        mapView.removeAnnotations(existingAnnotations)
        
        // Add appointment annotations
        let appointmentAnnotations = appointments.compactMap { appointment -> AppointmentAnnotation? in
            // For now, create sample locations around the user location or default location
            let baseLocation = userLocation ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            let randomOffset = 0.01 // Small offset for demo purposes
            let randomLat = baseLocation.latitude + Double.random(in: -randomOffset...randomOffset)
            let randomLng = baseLocation.longitude + Double.random(in: -randomOffset...randomOffset)
            
            let annotation = AppointmentAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: randomLat, longitude: randomLng)
            annotation.title = appointment.client.name
            annotation.subtitle = "\(appointment.pet.name) - \(appointment.time.formatted(.dateTime.hour().minute()))"
            annotation.appointment = appointment
            return annotation
        }
        
        mapView.addAnnotations(appointmentAnnotations)
        
        // Show all appointments and user location
        if !appointmentAnnotations.isEmpty {
            let allAnnotations = appointmentAnnotations as [MKAnnotation]
            mapView.showAnnotations(allAnnotations, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Handle user location annotation
            if annotation is MKUserLocation {
                return nil // Use default user location view
            }
            
            // Handle appointment annotations
            if let appointmentAnnotation = annotation as? AppointmentAnnotation {
                let identifier = "AppointmentAnnotation"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = true
                    
                    // Add a detail button
                    let detailButton = UIButton(type: .detailDisclosure)
                    annotationView?.rightCalloutAccessoryView = detailButton
                } else {
                    annotationView?.annotation = annotation
                }
                
                // Customize the marker appearance
                if let markerView = annotationView as? MKMarkerAnnotationView {
                    markerView.markerTintColor = .orange
                    markerView.glyphImage = UIImage(systemName: "pawprint.fill")
                }
                
                return annotationView
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let appointmentAnnotation = view.annotation as? AppointmentAnnotation {
                // Handle appointment detail tap
                // You could present a detail view or perform other actions
                print("Tapped appointment: \(appointmentAnnotation.appointment?.client.name ?? "Unknown")")
            }
        }
    }
}

// Custom annotation class for appointments
class AppointmentAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @objc dynamic var title: String?
    @objc dynamic var subtitle: String?
    var appointment: Appointment?
} 
