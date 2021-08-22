//
//  SimpleWidgetEntryView.swift
//  SimpleWidgetExtension
//
//  Created by Itamar Biton on 12/07/2021.
//

import WidgetKit
import SwiftUI

struct SimpleWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if entry.noLocation {
            Text("NO LOCATION!")
        } else if entry.noData {
            Text("NO DATA!")
        } else {
            VStack {
                Text(entry.date, style: .time)
                Text(entry.locationText)
                Text(entry.updateSource)
            }
        }
    }
}
