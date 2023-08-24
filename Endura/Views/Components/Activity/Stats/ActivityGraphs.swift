import Charts
import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct HoverableChart: View {
    private let graph: LineGraphData
    private let color: Color
    private let label: String
    private let valueModifier: (Double) -> String
    @Binding private var xPosition: Int

    public init(graph: LineGraphData, xPosition: Binding<Int>, color: Color, valueModifier: @escaping (Double) -> String = {
        String($0)
    }, label: String) {
        self.graph = graph
        _xPosition = xPosition
        self.color = color
        self.label = label
        self.valueModifier = valueModifier
    }

    public var body: some View {
        if !graph.filter({ $0.1 != 0 }).isEmpty {
            Text(label)
                .font(.title3)
                .padding()
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
                        Text("\(valueModifier(pace))")
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
            let elevationGraph = activityData.getGraph(for: .elevation)
            let heartRateGraph = activityData.getGraph(for: .heartRate)
            let powerGraph = activityData.getGraph(for: .power)
            let strideLengthGraph = activityData.getGraph(for: .strideLength)
            let verticleOscillation = activityData.getGraph(for: .verticleOscillation)

            if #available(iOS 16.0, *) {
                HoverableChart(graph: paceGraph, xPosition: $xPosition, color: .blue, valueModifier: ConversionUtils.convertMpsToMpm, label: "Pace")
                HoverableChart(graph: cadenceGraph, xPosition: $xPosition, color: .red, label: "Cadence")
                HoverableChart(graph: elevationGraph, xPosition: $xPosition, color: .green, label: "Elevation")
                HoverableChart(graph: heartRateGraph, xPosition: $xPosition, color: .orange, label: "Heart Rate")
                HoverableChart(graph: powerGraph, xPosition: $xPosition, color: .purple, label: "Power")
                HoverableChart(graph: strideLengthGraph, xPosition: $xPosition, color: .yellow, label: "Stride Length")
                HoverableChart(graph: verticleOscillation, xPosition: $xPosition, color: .pink, label: "Verticle Oscillation")
            } else {
                LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
                LineGraph(data: cadenceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: CadenceLineGraphStyle())
                LineGraph(data: elevationGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: ElevationLineGraphStyle())
                LineGraph(data: heartRateGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: HeartRateLineGraphStyle())
                LineGraph(data: powerGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: PowerLineGraphStyle())
                LineGraph(data: strideLengthGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: StrideLengthLineGraphStyle())
                LineGraph(data: verticleOscillation, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: VerticleOscillationLineGraphStyle())
            }
        }
    }
}
