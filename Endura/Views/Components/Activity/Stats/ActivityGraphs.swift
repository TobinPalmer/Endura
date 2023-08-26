import Charts
import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct HoverableChart: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel

    private let graph: LineGraphData
    private let color: Color
    private let label: String
    private let valueModifier: (Double) -> String
    private let workoutStart: Date
    private let workoutEnd: Date
    @Binding private var xPosition: Int

    public init(workoutStart: Date, workoutEnd: Date, graph: LineGraphData, xPosition: Binding<Int>, color: Color, valueModifier: @escaping (Double) -> String = {
        String($0)
    }, label: String) {
        self.workoutStart = workoutStart
        self.workoutEnd = workoutEnd
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
            .frame(width: UIScreen.main.bounds.width - 20, height: 200)
            .border(Color.gray)
            .gesture(DragGesture(minimumDistance: 10)
                .onChanged { value in
                    activityViewModel.analysisPosition = graph[safe: xPosition]?.0
                    activityViewModel.workoutStartDate = workoutStart
                    activityViewModel.workoutEndDate = workoutEnd
                    activityViewModel.workoutDuration = workoutEnd.timeIntervalSince(workoutStart)

                    let x = value.location.x
                    let max = graph.count - 1
                    let width = UIScreen.main.bounds.width - 20
                    let index = Int((x / width) * CGFloat(max)) + 3
                    xPosition = index
                }
            )
            .chartOverlay { _ in
                let _ = print("Changed xposition to \(xPosition)")
                VStack(spacing: 0) {
                    if let pace = graph[safe: xPosition]?.1 {
                        Text("\(valueModifier(pace)) at \(graph[safe: xPosition]?.0.formatted() ?? "")")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding()
                            .foregroundColor(.white)
                            .background(color)
                            .cornerRadius(5)
                    }
                }
                .position(x: CGFloat(xPosition) / CGFloat(max(1, graph.count - 1)) * UIScreen.main.bounds.width, y: 100)

                // Line to show where the user is
                Rectangle()
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(width: 1, height: 200)
                    .position(x: (CGFloat(xPosition) / CGFloat(max(1, graph.count - 1)) * UIScreen.main.bounds.width) - 12, y: 0)
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
//        HoverableChart(graph: paceGraph, xPosition: $xPosition, color: .blue, valueModifier: ConversionUtils.convertMpsToMpm, label: "Pace")
//        HoverableChart(graph: cadenceGraph, xPosition: $xPosition, color: .red, valueModifier: ConversionUtils.round, label: "Cadence")
//        HoverableChart(graph: elevationGraph, xPosition: $xPosition, color: .green, valueModifier: ConversionUtils.round, label: "Elevation")
//        HoverableChart(graph: powerGraph, xPosition: $xPosition, color: .purple, valueModifier: ConversionUtils.round, label: "Power")
//        HoverableChart(graph: strideLengthGraph, xPosition: $xPosition, color: .yellow, valueModifier: ConversionUtils.round, label: "Stride Length")
//        HoverableChart(graph: verticleOscillation, xPosition: $xPosition, color: .pink, valueModifier: ConversionUtils.round, label: "Verticle Oscillation")
                HoverableChart(workoutStart: activityData.workoutStart, workoutEnd: activityData.workoutStart + activityData.duration, graph: paceGraph, xPosition: $xPosition, color: .blue, valueModifier: ConversionUtils.convertMpsToMpm, label: "Pace")
                HoverableChart(workoutStart: activityData.workoutStart, workoutEnd: activityData.workoutStart + activityData.duration, graph: cadenceGraph, xPosition: $xPosition, color: .red, valueModifier: ConversionUtils.round, label: "Cadence")
                HoverableChart(workoutStart: activityData.workoutStart, workoutEnd: activityData.workoutStart + activityData.duration, graph: elevationGraph, xPosition: $xPosition, color: .green, valueModifier: ConversionUtils.round, label: "Elevation")
                HoverableChart(workoutStart: activityData.workoutStart, workoutEnd: activityData.workoutStart + activityData.duration, graph: powerGraph, xPosition: $xPosition, color: .purple, valueModifier: ConversionUtils.round, label: "Power")
                HoverableChart(workoutStart: activityData.workoutStart, workoutEnd: activityData.workoutStart + activityData.duration, graph: strideLengthGraph, xPosition: $xPosition, color: .yellow, valueModifier: ConversionUtils.round, label: "Stride Length")
                HoverableChart(workoutStart: activityData.workoutStart, workoutEnd: activityData.workoutStart + activityData.duration, graph: verticleOscillation, xPosition: $xPosition, color: .pink, valueModifier: ConversionUtils.round, label: "Verticle Oscillation")
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
