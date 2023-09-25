import Charts
import Foundation
import SwiftUI

struct DailySummaryGraph: View {
    @EnvironmentObject private var activeUserModel: ActiveUserModel

    @State private var selectedDay: WeekDay? = nil

    var body: some View {
        VStack {
            Chart {
                ForEach(WeekDay.eachDay(), id: \.self) { day in
                    let miles = activeUserModel.training.getTrainingDay(day).summary.getMiles()
                    BarMark(
                        x: .value("Day", day.getShortName()),
                        y: .value("Miles", miles)
                    )
                    .foregroundStyle(selectedDay == day ? .red : .blue)
                    .annotation {
                        if selectedDay == day && miles > 0 {
                            Text("\(ConversionUtils.round(miles)) mi")
                                .font(.title3)
                        } else {
                            Text("")
                                .font(.title3)
                        }
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
                                    if let day = proxy.value(atX: value.location.x - origin.x, as: String.self) {
                                        selectedDay = WeekDay.day(from: day)
                                    }
                                }
                                .onEnded { _ in
                                    selectedDay = nil
                                }
                        )
                }
            }
        }
        .padding()
    }
}
