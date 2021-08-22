//
//  LocationService+LocationData.swift
//  SimpleTracker
//
//  Created by Itamar Biton on 14/07/2021.
//

import CoreLocation

extension LocationService {
    struct LocationData: Codable {
        let lat: Double
        let lon: Double
        let date: Date
        let name: String?
    }
}

extension LocationService.LocationData {
    init(location: CLLocation, name: String? = nil) {
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        date = Date()
        self.name = name
    }

    func toCLLocation() -> CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }
}
