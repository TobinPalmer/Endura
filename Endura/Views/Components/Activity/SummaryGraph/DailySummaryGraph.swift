import Charts
import Foundation
import SwiftUI
import SwiftUICalendar

struct DailySummaryGraph: View {
    @EnvironmentObject private var activeUserModel: ActiveUserModel

    @State private var selectedDay: WeekDay? = nil

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Picker(
                        selection: .constant(YearMonthDay.current),
                        label: Text("Day")
                    ) {
                        Text("This Week")
                        Text("Last Week")
                        Text("This Month")
                        Text("Last Month")
                    }
                }
                Chart {
                    ForEach(WeekDay.eachDay(), id: \.self) { day in
                        let miles = activeUserModel.training.getTrainingDay(day).summary.getMiles()
                        BarMark(
                            x: .value("Day", day.getShortName()),
                            y: .value("Miles", miles),
                            width: 20
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .foregroundStyle(
                            Color.accentColor
                        )
                        .annotation {
                            VStack {
                                if selectedDay == day && miles > 0 {
                                    Text("\(FormattingUtils.formatMiles(miles)) mi")
                                        .fontColor(.secondary)
                                        .fontWeight(.bold)
                                        .font(.body)
                                }
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
                                .fontColor(.secondary)
                                .padding(.top, 6)
                        }
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let origin = geometry[proxy.plotAreaFrame].origin
                                        if let day = proxy
                                            .value(atX: value.location.x - origin.x, as: String.self)
                                        {
                                            if selectedDay != WeekDay.day(from: day) {
                                                selectedDay = WeekDay.day(from: day)
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        if selectedDay != nil {
                                            selectedDay = nil
                                        }
                                    }
                            )
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .enduraDefaultBox()

            if WeekDay.eachDay().map({ day in activeUserModel.training.getTrainingDay(day).summary.getMiles() })
                .max() ?? 0 == 0
            {
                VStack {
                    Text("Start running to see your progress here!")
                        .font(.body)
                        .fontColor(.secondary)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                }
            }
        }
    }
}
