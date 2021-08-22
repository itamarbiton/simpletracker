//
//  SimpleTrackerApp.swift
//  SimpleTracker
//
//  Created by Itamar Biton on 01/07/2021.
//

import SwiftUI

@main
struct SimpleTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: StatusViewModel())
        }
    }
}
