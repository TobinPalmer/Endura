import Charts
import Foundation
import SwiftUI

struct ActivityGraphsView: View {
    private let activityData: ActivityDataWithRoute

    @State private var xPosition = 0

    init(_ activityData: ActivityDataWithRoute) {
        self.activityData = activityData
    }

    public var body: some View {
        VStack {
            let paceGraph = activityData.getGraph(for: .pace) // [(x, y)]
            let cadenceGraph = activityData.getGraph(for: .cadence) // [(x, y)]

            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(paceGraph, id: \.0) { tuple in
                        LineMark(
                            x: .value("X values", tuple.0),
                            y: .value("Y values", tuple.1),
                            series: .value("Series", "Pace")
                        ).foregroundStyle(.blue).interpolationMethod(.catmullRom)
                    }

                    ForEach(cadenceGraph, id: \.0) { tuple in
                        LineMark(
                            x: .value("X values", tuple.0),
                            y: .value("Y values", tuple.1),
                            series: .value("Series", "Cadence")
                        ).foregroundStyle(.green).interpolationMethod(.catmullRom)
                    }
                }

//        Chart(combined, id: \.1) { tuple in
//          LineMark(
//            x: .value("X values", tuple.1),
//            y: .value("Y values", tuple.2)
//          )
//            .foregroundStyle(
//              tuple.0 == "pace" ? .red : .blue
//            )
//        }
//          .gesture(DragGesture(minimumDistance: 10)
//            .onChanged { value in
//              let x = value.location.x
//              let max = paceGraph.count - 1
//              let width = UIScreen.main.bounds.width - 20
//              let index = Int((x / width) * CGFloat(max))
//              xPosition = index
//            }
//          )
//          .frame(height: 300)
//          .chartOverlay { _ in
//            VStack(spacing: 0) {
//              if let pace = paceGraph[safe: xPosition]?.1 {
//                Text("\(pace.rounded(toPlaces: 2))")
//                  .font(.system(size: 10))
//                  .padding()
//                  .foregroundColor(.red)
//                  .background(.gray.opacity(0.5))
//              }
//            }
//              .border(.red)
//          }
//        Text("\(xPosition)")
            }
        }
    }
}
