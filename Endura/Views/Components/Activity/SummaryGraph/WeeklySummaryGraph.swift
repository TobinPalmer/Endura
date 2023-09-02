import Foundation
#if canImport(Charts)
    import Charts
#endif

import SwiftUI

private final class WeeklySumaryGraphModel: ObservableObject {}

struct WeeklySummaryGraph: View {
    @StateObject private var viewModel = WeeklySumaryGraphModel()
    private var data: [WeeklyGraphData]

    public init(_ data: [WeeklyGraphData]) {
        self.data = data

        var mergedData: [WeeklyGraphData] = []
        for i in 1 ... data.count {
            if !mergedData.contains(where: { $0.day == data[i - 1].day }) {
                mergedData.append(WeeklyGraphData(day: data[i - 1].day, distance: data[i - 1].distance))
            } else {
                mergedData[mergedData.firstIndex(where: { $0.day == data[i - 1].day })!].distance += data[i - 1].distance
            }
        }

        self.data = mergedData

        for i in Days.allCases {
            if !self.data.contains(where: { $0.day == i }) {
                self.data.append(WeeklyGraphData(day: i, distance: 0))
            }
        }

        self.data.sort {
            let dayOrder: [Days] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
            return dayOrder.firstIndex(of: $0.day)! < dayOrder.firstIndex(of: $1.day)!
        }

        print("DATA", self.data.count)
    }

    public var body: some View {
        VStack {
            Text("Weekly Summary Graph")
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(data, id: \.self) { data in
                        BarMark(
                            x: .value("Week", data.day.rawValue),
                            y: .value("Miles", data.distance)
                        )
                    }
                }
//          .chartXAxis {
//            AxisMarks(values: data.map {
//              $0.day
//            }) { value in
//              AxisValueLabel {
//                VStack {
//                }
//              }
//            }
//          }
            } else {
                Text("This week you ran 27.8 miles")
            }
        }
        .frame(width: 250, height: 250)
    }
}
