import Foundation
import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()

        entries.append(SimpleEntry(date: currentDate, configuration: configuration))

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct EnduraWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            if let userDefaults = UserDefaults(suiteName: "group.com.endurapp.EnduraApp") {
                Text(userDefaults.string(forKey: "test") ?? "NIL")
                Text(userDefaults.string(forKey: "dailyDistance-1") ?? "DAY NIL")
            }

            Text("Distance Type")
            Text(entry.configuration.distanceType.rawValue)
        }
    }
}

struct EnduraWidget: Widget {
    let kind: String = "EnduraWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            EnduraWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall])
    }
}

private extension ConfigurationAppIntent {
    static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.distanceType = .mile
        return intent
    }

    static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.distanceType = .kilo
        return intent
    }
}

#Preview(as: .systemSmall) {
    EnduraWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
