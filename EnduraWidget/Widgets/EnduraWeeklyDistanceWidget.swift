import AppIntents
import Charts
import Foundation
import SwiftUI
import SwiftUICalendar
import WidgetKit

private final class EnduraWidgetEntryViewModel: ObservableObject {
    fileprivate var userDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.endurapp.EnduraApp")
    }

    @Published fileprivate var totalDistance: Double = 0.0
    @Published fileprivate var weeklyGoal: Double = 0.0
    @Published fileprivate var trainingDay: DailyTrainingDataDocument = .init(
        date: YearMonthDay.current.toCache(),
        type: .none,
        goals: [],
        summary: .init(distance: 0, duration: 0, activities: 0)
    )

    fileprivate init() {
        var distance = 0.0
        if let userDefaults = userDefaults {
            if let trainingDayData = DailyTrainingDataDocument
                .fromJSON(userDefaults.string(forKey: "trainingDay") ?? "")
            {
                trainingDay = trainingDayData
            }

            for day in WeekDay.eachDay() {
                let miles = Double(userDefaults.string(forKey: "dailyDistance-\(day.rawValue)") ?? "")
                distance += miles ?? 0.0
            }
        }

        totalDistance = distance

        // TODO: Get this from the the userDefaults
        weeklyGoal = 10000
    }
}

private enum EnduraWeeklyDistanceWidgetDistanceType: String, CaseIterable, AppEnum {
    case mile
    case kilo

    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Timeframe"

    public static var caseDisplayRepresentations: [EnduraWeeklyDistanceWidgetDistanceType: DisplayRepresentation] = [
        .mile: "Miles",
        .kilo: "Kilometers",
    ]
}

struct EnduraWeeklyDistanceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    @Parameter(title: "Distance", default: .mile)
    fileprivate var distanceType: EnduraWeeklyDistanceWidgetDistanceType
}

public struct SimpleEntry: TimelineEntry {
    public let date: Date
    let configuration: EnduraWeeklyDistanceIntent
}

public struct EnduraWeeklyDistanceWidget: Widget {
    let kind: String = "EnduraDistanceWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: EnduraWeeklyDistanceIntent.self,
                               provider: WidgetProvider())
        { entry in
            EnduraWeeklyDistanceWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
    }
}

struct EnduraWeeklyDistanceWidgetView: View {
    public var entry: WidgetProvider.Entry
    private let viewModel = EnduraWidgetEntryViewModel()

    public var body: some View {
        VStack {
            if let userDefaults = viewModel.userDefaults {
                HStack {
                    VStack {
                        ZStack {
                            let progressRingSize = 100

                            Circle()
                                .stroke(Color.accentColor.opacity(0.2), lineWidth: 8)
                                .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
                                .foregroundColor(.red)

                            Circle()
                                .trim(from: 0, to: CGFloat(viewModel.totalDistance / viewModel.weeklyGoal))
                                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: CGFloat(progressRingSize), height: CGFloat(progressRingSize))
                                .rotationEffect(.degrees(-90))

                            VStack {
                                Text("\(viewModel.trainingDay.goals.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
//                Text("Total Distance:")
//                  .font(.caption)
//                  .fontWeight(.bold)
//                  .foregroundColor(.secondary)

                                Text(
                                    "\(FormattingUtils.formatMiles(ConversionUtils.metersToMiles(viewModel.totalDistance))) mi"
                                )
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            }
                        }
                    }
                    VStack {
                        Chart {
                            ForEach(WeekDay.eachDay(), id: \.self) { day in
                                let miles = Double(userDefaults.string(forKey: "dailyDistance-\(day.rawValue)") ?? "")
                                BarMark(
                                    x: .value("Day", day.getShortName()),
                                    y: .value("Miles", miles ?? 0.0),
                                    width: 20
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .foregroundStyle(
                                    Color.accentColor
                                )
                            }
                        }
                        .chartYAxis(.hidden)
                        .chartXAxis {
                            AxisMarks(values: WeekDay.eachDay().map { day in
                                day.getShortName()
                            }) { value in
                                AxisValueLabel {
                                    Text(WeekDay(rawValue: value.index)!.getShortName())
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("Error")
            }
        }
    }
}
