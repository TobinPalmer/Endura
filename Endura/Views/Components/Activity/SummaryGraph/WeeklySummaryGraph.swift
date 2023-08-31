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
    }

    public var body: some View {
        VStack {
            Text("Weekly Summary Graph")
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(data, id: \.self) { data in
                        LineMark(
                            x: .value("Week", data.day),
                            y: .value("Miles", data.distance)
                        )
                    }
                }
                .chartYAxis {
                    AxisMarks(
                        format: Decimal.FormatStyle.Percent.percent.scale(1)
                    )
                }

            } else {
                Text("This week you ran 27.8 miles")
            }
        }
        .frame(width: 250, height: 250)
    }
}
