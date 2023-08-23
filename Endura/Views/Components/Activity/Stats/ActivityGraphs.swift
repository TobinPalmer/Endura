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
            let paceGraph = activityData.getGraph(for: .pace)

            if #available(iOS 16.0, *) {
                Chart(paceGraph, id: \.1) { tuple in
                    LineMark(
                        x: .value("X values", tuple.0),
                        y: .value("Y values", tuple.1)
                    )
                }
                .gesture(DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        let x = value.location.x
                        let max = paceGraph.count - 1
                        let width = UIScreen.main.bounds.width - 20
                        let index = Int((x / width) * CGFloat(max))
                        xPosition = index
                    }
                )
                .frame(height: 300)
                .chartOverlay { _ in
                    VStack(spacing: 0) {
                        if let pace = paceGraph[safe: xPosition]?.1 {
                            Text("\(pace.rounded(toPlaces: 2))")
                                .font(.system(size: 10))
                                .padding()
                                .foregroundColor(.red)
                                .background(.gray.opacity(0.5))
                        }
                    }
                    .border(.red)
                }
                Text("\(xPosition)")

                Stepper("", value: $xPosition, in: 0 ... paceGraph.count - 2)
                //            let width: CGFloat
                //            let height: CGFloat
                //
                //            if #available(iOS 17.0, *) {
                //              let _ = width = proxy.plotSize.width
                //              let _ = height = proxy.plotSize.height
                //            } else {
                //              let _ = width = proxy.plotAreaSize.width
                //              let _ = height = proxy.plotAreaSize.height
                //            }
                //
                //            VStack {
                //              Text("Pace")
                //                .font(.title)
                //                .fontWeight(.bold)
                //                .foregroundColor(.red)
                //                .padding(.top, 10)
                //              Text("min/mile")
                //                .font(.title)
                //                .fontWeight(.bold)
                //                .foregroundColor(.red)
                //                .padding(.bottom, 10)
                //            }
                //              .frame(width: width, height: height, alignment: .center)
                //          }
            }
        }
    }
}
