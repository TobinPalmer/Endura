import Charts
import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct HoverableChart: View {
    private let graph: LineGraphData
    private let color: Color
    @Binding private var xPosition: Int

    public init(graph: LineGraphData, xPosition: Binding<Int>, color: Color) {
        self.graph = graph
        _xPosition = xPosition
        self.color = color
    }

    public var body: some View {
        Chart {
            ForEach(graph, id: \.0) { tuple in
                LineMark(
                    x: .value("X values", tuple.0),
                    y: .value("Y values", tuple.1),
                    series: .value("Series", "Pace")
                ).foregroundStyle(color).interpolationMethod(.catmullRom)
            }
        }
        .gesture(DragGesture(minimumDistance: 10)
            .onChanged { value in
                let x = value.location.x
                let max = graph.count - 1
                let width = UIScreen.main.bounds.width - 20
                let index = Int((x / width) * CGFloat(max))
                xPosition = index
            }
        )
        .chartOverlay { _ in
            VStack(spacing: 0) {
                if let pace = graph[safe: xPosition]?.1 {
                    Text("\(pace.rounded(toPlaces: 2))")
                        .font(.system(size: 10))
                        .padding()
                        .foregroundColor(.red)
                        .background(.gray.opacity(0.5))
                }
            }
            .border(.red)
        }
    }
}

struct ActivityGraphsView: View {
    private let activityData: ActivityDataWithRoute

    @State private var xPosition = 0

    init(_ activityData: ActivityDataWithRoute) {
        self.activityData = activityData
    }

    public var body: some View {
        VStack {
            let paceGraph = activityData.getGraph(for: .pace)
            let cadenceGraph = activityData.getGraph(for: .cadence)

            if #available(iOS 16.0, *) {
                HoverableChart(graph: paceGraph, xPosition: $xPosition, color: .blue)
                HoverableChart(graph: cadenceGraph, xPosition: $xPosition, color: .red)
            } else {
                LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
                LineGraph(data: cadenceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: CadenceLineGraphStyle())
            }
        }
    }
}
