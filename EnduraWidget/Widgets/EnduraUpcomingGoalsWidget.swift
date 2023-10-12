import AppIntents
import Charts
import Foundation
import SwiftUI
import SwiftUICalendar
import WidgetKit

final class EnduraUpcomingGoalsWidgetViewModel: ObservableObject {
    fileprivate var userDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.endurapp.EnduraApp")
    }

    @Published var trainingDay: DailyTrainingDataDocument = .init(
        date: YearMonthDay.current.toCache(),
        type: .none,
        goals: [],
        summary: .init(distance: 0, duration: 0, activities: 0)
    )

    fileprivate init() {}
}

struct Provider: AppIntentTimelineProvider {
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

public struct EnduraUpcomingGoalsWidget: Widget {
    let kind: String = "EnduraUpcomingGoalsWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: EnduraWeeklyDistanceIntent.self, provider: Provider()) { entry in
            EnduraUpcomingGoalsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
    }
}

struct EnduraUpcomingGoalsWidgetView: View {
    public var entry: Provider.Entry
    private let viewModel = EnduraUpcomingGoalsWidgetViewModel()

    public var body: some View {
        Text("HI widget 2")
    }
}
