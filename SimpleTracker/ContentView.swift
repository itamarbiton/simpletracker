//
//  ContentView.swift
//  SimpleTracker
//
//  Created by Itamar Biton on 01/07/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: StatusViewModel

    var body: some View {
        VStack {
            viewModel.enabled ? Text("Enabled") : Text("Disabled")
            Button("Request When In Use Access") {
                viewModel.requestWhenInUseAccess()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: StatusViewModel())
    }
}
