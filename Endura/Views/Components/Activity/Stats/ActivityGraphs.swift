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

            let combined = Array(zip(paceGraph, cadenceGraph)).flatMap {
                [("pace", $0.0.0, $0.0.1), ("cadence", $0.1.0, $0.1.1)]
            }

            let _ = print(combined)

            if #available(iOS 16.0, *) {
                Chart(combined, id: \.0) { tuple in
                    LineMark(
                        x: .value("X values", tuple.1),
                        y: .value("Y values", tuple.2)
                    )
                    .foregroundStyle(
                        tuple.0 == "pace" ? .red : .blue
                    )
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
