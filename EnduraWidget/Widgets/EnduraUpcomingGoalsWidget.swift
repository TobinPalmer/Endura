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

    fileprivate init() {
        if let userDefaults = userDefaults {
            if let trainingDayData = DailyTrainingDataDocument
                .fromJSON(userDefaults.string(forKey: "trainingDay") ?? "")
            {
                trainingDay = trainingDayData
            }
        }
    }
}

public struct EnduraUpcomingGoalsWidget: Widget {
    let kind: String = "EnduraUpcomingGoalsWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: EnduraWeeklyDistanceIntent.self,
                               provider: WidgetProvider())
        { entry in
            EnduraUpcomingGoalsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
    }
}

struct EnduraUpcomingGoalsWidgetView: View {
    public var entry: WidgetProvider.Entry
    private let viewModel = EnduraUpcomingGoalsWidgetViewModel()

    public var body: some View {
        if viewModel.trainingDay.goals.isEmpty {
            Text("No upcoming goals, click here to add one")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        } else {
            let goal = viewModel.trainingDay.goals[0]
            HStack {
                VStack {
                    HStack {
                        Text("\(goal.type.rawValue) Day")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(goal.type.getColor())
                            .alignFullWidth()

                        Spacer()

                        if goal.progress?.allCompleted() ?? false {
                            Image(systemName: "checkmark.circle")
                                .font(.title)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.bottom, 1)

                    Text(String(describing: goal.description))
                        .font(.body)
                        .fontColor(.secondary)
                        .alignFullWidth()

                    ActivityPostStats(distance: goal.getDistance(), duration: goal.getTime())
                }
            }
        }
    }
}
