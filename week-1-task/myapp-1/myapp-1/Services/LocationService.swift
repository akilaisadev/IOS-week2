//
//  LocationService.swift
//  myapp-1
//
//  service managing core location and gps coordinates for game sessions
//

import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let manager = CLLocationManager()
    
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    
    // default fallback coords if permission is denied or simulator has no gps
    let fallbackLat: Double = 6.9271
    let fallbackLon: Double = 79.8612
    
    override private init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authStatus = manager.authorizationStatus
    }
    
    // request location permission from user
    func requestPermission() {
        manager.startUpdatingLocation()
    }
    
    // get current lat or fallback
    var currentLatitude: Double {
        latitude ?? fallbackLat
    }
    
    // get current lon or fallback
    var currentLongitude: Double {
        longitude ?? fallbackLon
    }
    
    // delegate methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error: \(error.localizedDescription)")
    }
}
