//
//  SimpleWidget.swift
//  SimpleWidget
//
//  Created by Itamar Biton on 01/07/2021.
//

import CoreLocation
import WidgetKit
import SwiftUI
import Intents
import os

struct Provider: IntentTimelineProvider {
    typealias Entry = SimpleEntry

    var viewModel: ProviderViewModel
    let locationService = LocationService.shared
    let networkService = NetworkService.shared

    let locationManager = CLLocationManager()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            updateSource: "placeholder",
            locationText: viewModel.locationText,
            configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            updateSource: "getSnapshot",
            locationText: viewModel.locationText,
            configuration: configuration)

        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        guard let locationData = locationService.mostRecentLocationData, locationData.date.timeIntervalSinceNow < 120 else {
            os_log("@@ GET TIMELINE: LOCATION IS NOT FRESH ENOUGH, REQUESTING NEW!")
            locationService.requestLocation()
            let timeline = Timeline(entries: [SimpleEntry.noLocation], policy: .atEnd)
            completion(timeline)
            return
        }

        let entry = SimpleEntry(
            date: Date(),
            updateSource: "getTimeline",
            locationText: viewModel.locationText,
            configuration: configuration)

        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var noLocation: Bool = false
    var noData: Bool = false
    let date: Date
    let updateSource: String
    let locationText: String
    let configuration: ConfigurationIntent?
}

extension SimpleEntry {
    static var noLocation: SimpleEntry {
        SimpleEntry(
            noLocation: true,
            date: Date(),
            updateSource: "",
            locationText: "",
            configuration: nil)
    }

    static var noData: SimpleEntry {
        SimpleEntry(
            noData: true,
            date: Date(),
            updateSource: "",
            locationText: "",
            configuration: nil)
    }
}

@main
struct SimpleWidget: Widget {
    let kind: String = "SimpleWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider(viewModel: ProviderViewModel())
        ) { entry in SimpleWidgetEntryView(entry: entry) }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .onBackgroundURLSessionEvents(matching: NetworkService.urlSessionIdentifier) { (identifier, completion) in
            os_log("@@ GOT IDENTIFIER! \(identifier)")
            NetworkService.shared.backgroundCompletionHandler = completion
        }
    }
}

struct SimpleWidget_Previews: PreviewProvider {
    static var previews: some View {
        SimpleWidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                updateSource: "previews",
                locationText: "N/A",
                configuration: ConfigurationIntent())
        ).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
