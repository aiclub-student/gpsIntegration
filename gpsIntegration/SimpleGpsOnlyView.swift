//
//  ContentView.swift
//  gpsIntegration
//
//  Created by Amit Gupta on 10/1/22.
//

import SwiftUI
import CoreLocationUI

struct SimpleGpsOnlyView: View {
    @StateObject var locationManager = LocationManager()

    var body: some View {
        VStack {
            if let location = locationManager.location {
                Text("Your location: \(location.latitude), \(location.longitude)")
            }

            LocationButton {
                locationManager.requestLocation()
            }
            .frame(height: 44)
            .padding()
        }
    }
}

struct SimpleGpsOnlyView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleGpsOnlyView()
    }
}
