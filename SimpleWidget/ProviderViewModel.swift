//
//  ProviderViewModel.swift
//  SimpleWidgetExtension
//
//  Created by Itamar Biton on 11/07/2021.
//

import CoreLocation
import WidgetKit
import os

class ProviderViewModel: NSObject {
    var locationText: String {
        let isEnabled = LocationService.shared.isAuthorizedForWidgetUpdates
        if isEnabled {
            if let location = LocationService.shared.mostRecentLocationData, let name = location.name {
                return "Most recent location is \(name)"
            } else { return "No recent location fetch" }
        } else { return "Location access is disabled" }
    }
}

