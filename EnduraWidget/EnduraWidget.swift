import Charts
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

final class EnduraWidgetEntryViewModel: ObservableObject {
    fileprivate var userDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.endurapp.EnduraApp")
    }

    @Published var totalDistance: Double = 0.0
    @Published var weeklyGoal: Double = 0.0

    init() {
        var distance = 0.0
        if let userDefaults = userDefaults {
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

struct EnduraWidgetEntryView: View {
    public var entry: Provider.Entry
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

struct EnduraWidget: Widget {
    let kind: String = "EnduraWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            EnduraWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
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
