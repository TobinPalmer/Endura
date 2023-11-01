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
//                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct EnduraUpcomingGoalsWidgetView: View {
    public var entry: WidgetProvider.Entry
    private let viewModel = EnduraUpcomingGoalsWidgetViewModel()

    public var body: some View {
        if viewModel.trainingDay.type == .rest {
            Text("Today is a rest day, no goals for today!")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .containerBackground(LinearGradient(
                    gradient: Gradient(colors: [Color("EnduraBlue").opacity(0.7), Color("EnduraBlue")]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                ), for: .widget)
        } else if viewModel.trainingDay.goals.isEmpty {
            Text("No upcoming goals, click here to add one")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .containerBackground(LinearGradient(
                    gradient: Gradient(colors: [.gray.opacity(0.7), .gray]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                ), for: .widget)
        } else {
            let goal = viewModel.trainingDay.goals[0]
            GeometryReader { geometry in
                VStack {
                    HStack {
                        let big = geometry.size.width > 170
                        if big {
                            WidgetTrainingGoal(goal, big: true)
                                .frame(width: 3 * geometry.size.width / 5)
                            WidgetTrainingGoalProgress(goal)
                                .frame(width: 2 * geometry.size.width / 5)
                        } else {
                            WidgetTrainingGoal(goal)
                        }
                    }
                }
            }
            .containerBackground(LinearGradient(
                gradient: Gradient(colors: [goal.type.getColor().opacity(0.7), goal.type.getColor()]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            ), for: .widget)
        }
    }
}
