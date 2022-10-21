//
//  MyLocationManager.swift
//  gpsIntegration
//
//  Created by Amit Gupta on 10/1/22.
//

import Foundation
import CoreLocation
import MapKit


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var area=MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5, longitude: -121.9), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        guard let location = location else {
            return
        }
        print("Got updated Location information: \(location)")
        area=MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("Saw Location error \(error)")
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}

