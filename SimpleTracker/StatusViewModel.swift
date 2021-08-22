//
//  StatusViewModel.swift
//  SimpleTracker
//
//  Created by Itamar Biton on 11/07/2021.
//

import Foundation
import CoreLocation

class StatusViewModel: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    @Published var enabled: Bool = false

    override init() {
        super.init()
        manager.delegate = self
        fetchStatus()
    }

    private func fetchStatus() {
        let status = manager.authorizationStatus
        enabled = status == .authorizedAlways || status == .authorizedWhenInUse
    }
}

extension StatusViewModel: StatusViewModelActions {
    func requestWhenInUseAccess() {
        manager.requestWhenInUseAuthorization()
    }
}

extension StatusViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        fetchStatus()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
