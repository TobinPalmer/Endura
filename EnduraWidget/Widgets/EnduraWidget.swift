import WidgetKit

struct WidgetProvider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: EnduraWeeklyDistanceIntent())
    }

    func snapshot(for configuration: EnduraWeeklyDistanceIntent, in _: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: EnduraWeeklyDistanceIntent, in _: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()

        entries.append(SimpleEntry(date: currentDate, configuration: configuration))

        return Timeline(entries: entries, policy: .atEnd)
    }
}
