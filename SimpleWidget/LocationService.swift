//
//  LocationService.swift
//  SimpleWidgetExtension
//
//  Created by Itamar Biton on 13/07/2021.
//

import WidgetKit
import CoreLocation
import os

class LocationService: NSObject {
    static let shared = LocationService()

    private let locationManager = CLLocationManager()

    var isAuthorizedForWidgetUpdates: Bool {
        locationManager.isAuthorizedForWidgetUpdates
    }

    var mostRecentLocationData: LocationData? {
        DiskService.getLocationData()
    }

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        os_log("@@ LOCATION SERVICE: RECEIVED LOCATION UPDATE")

        guard let location = locations.first else { return }

        if let recentLocation = mostRecentLocationData?.toCLLocation(), recentLocation.distance(from: location) < 60 {
            os_log("@@ LOCATION SERVICE: RECEIVED LOCATION TOO CLOSE, IGNORING...")
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                os_log("@@ LOCATION SERVIE: FAILED TO REVERSE GEOCODE COORDINATES: \(location.coordinate.latitude), \(location.coordinate.longitude), \(error.localizedDescription)")
                return
            }

            guard let placemark = placemarks?.first else { return }

            let locationData = LocationData(location: location, name: placemark.name)
            DiskService.writeLocationDataToDisk(locationData)

            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("@@ LOCATION SERVICE: FAILED TO GET LOCATION UPDATE, \(error.localizedDescription)")
    }
}
