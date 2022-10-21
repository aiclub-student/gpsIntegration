//
//  SimpleGpsMapView.swift
//  gpsIntegration
//
//  Created by Amit Gupta on 10/1/22.
//

import SwiftUI
import CoreLocationUI
import MapKit

struct SimpleGpsMapView: View {
    @StateObject var locationManager = LocationManager()
    
    //@State var address="1600 Pennsylvania Avenue, Washington D.C."
    @State var tracking=MapUserTrackingMode.follow
    //@State var center=CLLocationCoordinate2D(latitude: 37.0, longitude: -122.4)
    //@State var span=MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    //@State var area=MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5, longitude: -121.9), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    @State var annotation=MKPointAnnotation()

    var body: some View {
        VStack {
            if let location = locationManager.location {
                Text("My location: \(location.latitude), \(location.longitude)")
                Map(coordinateRegion:$locationManager.area, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: [annotation.coordinate]) {_ in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                }
            }

            LocationButton {
                locationManager.requestLocation()

            }
            .frame(height: 44)
            .padding()
        }
    }
}

struct SimpleGpsMapView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleGpsMapView()
    }
}
