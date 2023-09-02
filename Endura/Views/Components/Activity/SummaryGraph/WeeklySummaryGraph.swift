import Foundation
#if canImport(Charts)
    import Charts
#endif

import SwiftUI

private final class WeeklySumaryGraphModel: ObservableObject {}

struct WeeklySummaryGraph: View {
    @StateObject private var viewModel = WeeklySumaryGraphModel()
    private var data: [WeeklyGraphData]

    init(_ data: [WeeklyGraphData]) {
        self.data = data

        let mergedData = data.reduce(into: [WeeklyGraphData]()) { mergedData, currentData in
            if let existingIndex = mergedData.firstIndex(where: { $0.day == currentData.day }) {
                mergedData[existingIndex].distance += currentData.distance
            } else {
                mergedData.append(WeeklyGraphData(day: currentData.day, distance: currentData.distance))
            }
        }

        let presentDays = Set(mergedData.map {
            $0.day
        })
        let missingDays = Set(Days.allCases).subtracting(presentDays)

        let missingData = missingDays.map {
            WeeklyGraphData(day: $0, distance: 0)
        }
        let updatedData = mergedData + missingData

        let dayOrder: [Days] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        let sortedData = updatedData.sorted {
            dayOrder.firstIndex(of: $0.day)! < dayOrder.firstIndex(of: $1.day)!
        }

        self.data = sortedData
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
