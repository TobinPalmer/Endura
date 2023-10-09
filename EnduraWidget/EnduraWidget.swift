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

struct EnduraWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            if let userDefaults = UserDefaults(suiteName: "group.com.endurapp.EnduraApp") {
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
                            .annotation {
                                VStack {
//                    if selectedDay == day && miles > 0 {
//                      Text("\(FormattingUtils.formatMiles(miles)) mi")
//                        .fontColor(.secondary)
//                        .fontWeight(.bold)
//                        .font(.body)
//                    }
                                }
                                .frame(height: 20)
                            }
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
//            .chartOverlay { proxy in
//              GeometryReader { geometry in
//                Rectangle().fill(.clear).contentShape(Rectangle())
//                  .gesture(
//                    DragGesture(minimumDistance: 0)
                    ////                      .onChanged { value in
                    ////                        let origin = geometry[proxy.plotAreaFrame].origin
                    ////                        if let day = proxy.value(atX: value.location.x - origin.x, as:
                    // String.self) {
                    ////                          if selectedDay != WeekDay.day(from: day) {
                    ////                            selectedDay = WeekDay.day(from: day)
                    ////                          }
                    ////                        }
                    ////                      }
                    ////                      .onEnded { _ in
                    ////                        if selectedDay != nil {
                    ////                          selectedDay = nil
                    ////                        }
                    ////                      }
//                  )
//              }
//            }
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
