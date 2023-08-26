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

    public init(workoutStart: Date, workoutEnd: Date, graph: LineGraphData, color: Color, label: String, valueModifier: @escaping (Double) -> String = {
        String($0)
    }) {
        self.workoutStart = workoutStart
        self.workoutEnd = workoutEnd
        self.graph = graph
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
                        x: .value("Timestamp", tuple.0),
                        y: .value("Value", tuple.1)
                    ).foregroundStyle(color).interpolationMethod(.catmullRom)
                }

                if let analysisPosition = activityViewModel.analysisPosition {
                    RectangleMark(x: .value("Timestamp", analysisPosition), width: 1)
                        .foregroundStyle(.primary.opacity(1))
                        .annotation(
                            position: .top,
                            alignment: .center,
                            spacing: 0
                        ) {
                            let value = activityViewModel.getAnalysisValue(for: analysisPosition)?.pace
//                            let _ = print("Value: \()")
                            Text("\(value != nil ? valueModifier(value ?? 0) : "No Data") at \(analysisPosition.formatted(date: .omitted, time: .standard))")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding()
                                .foregroundColor(.white)
                                .background(color)
                                .cornerRadius(5)
                        }
                }
            }
                .frame(height: 200)
                .padding(.horizontal, 10)
                .border(Color.gray)
                .chartOverlay { (chartProxy: ChartProxy) in
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(DragGesture()
                            .onChanged { value in
                                activityViewModel.analysisPosition = chartProxy.value(
                                    atX: value.location.x
                                )
                                if let analysisPosition = activityViewModel.analysisPosition {
                                    if analysisPosition < workoutStart {
                                        activityViewModel.analysisPosition = workoutStart
                                    } else if analysisPosition > workoutEnd {
                                        activityViewModel.analysisPosition = workoutEnd
                                    }
                                }
                            }
                            .onEnded {
                                _ in
                                activityViewModel.analysisPosition = nil
                            }
                        )
                }
//                .chartOverlay { _ in
            ////                    let _ = print("Changed xposition to \(timestamp)")
//                    VStack(spacing: 0) {
            ////                        if let pace = graph[safe: timestamp]?.1 {
            ////                            Text("\(valueModifier(pace)) at \(graph[safe: timestamp]?.0.formatted() ?? "")")
            ////                                .font(.title3)
            ////                                .fontWeight(.semibold)
            ////                                .padding()
            ////                                .foregroundColor(.white)
            ////                                .background(color)
            ////                                .cornerRadius(5)
            ////                        }
//                    }
//                        .position(x: CGFloat(timestamp) / CGFloat(max(1, graph.count - 1)) * UIScreen.main.bounds.width, y: 100)

//                    // Line to show where the user is
//                    Rectangle()
//                        .stroke(Color.red, style: StrokeStyle(lineWidth: 1, dash: [5]))
//                        .frame(width: 1, height: 200)
//                        .position(x: (CGFloat(timestamp) / CGFloat(max(1, graph.count - 1)) * UIScreen.main.bounds.width) - 12, y: 0)
//                }
        }
    }
}

struct ActivityGraphsView: View {
    private let activityData: ActivityDataWithRoute

    @State private var timestamp: Date?

    init(_ activityData: ActivityDataWithRoute) {
        self.activityData = activityData
    }

    public var body: some View {
        VStack {
//            let paceGraph = activityData.getGraph(for: .pace)
//            let cadenceGraph = activityData.getGraph(for: .cadence)
//            let elevationGraph = activityData.getGraph(for: .elevation)
//            let heartRateGraph = activityData.getGraph(for: .heartRate)
//            let powerGraph = activityData.getGraph(for: .power)
//            let strideLengthGraph = activityData.getGraph(for: .strideLength)
//            let verticalOscillation = activityData.getGraph(for: .verticalOscillation)

            let graphData = activityData.getGraphData()
            let start = activityData.workoutStart
            let end = activityData.workoutStart + activityData.duration

//            let _ = print("Pace length: \(graphData.pace.count)")
//            let _ = print("Cadence length: \(graphData.cadence.count)")
//            let _ = print("Elevation length: \(graphData.elevation.count)")
//            let _ = print("Heart rate length: \(graphData.heartRate.count)")
//            let _ = print("Power length: \(graphData.power.count)")
//            let _ = print("Stride length length: \(graphData.strideLength.count)")
//            let _ = print("Vertical oscillation length: \(graphData.verticalOscillation.count)")

            if #available(iOS 16.0, *) {
//        HoverableChart(graph: paceGraph, xPosition: $xPosition, color: .blue, valueModifier: ConversionUtils.convertMpsToMpm, label: "Pace")
//        HoverableChart(graph: cadenceGraph, xPosition: $xPosition, color: .red, valueModifier: ConversionUtils.round, label: "Cadence")
//        HoverableChart(graph: elevationGraph, xPosition: $xPosition, color: .green, valueModifier: ConversionUtils.round, label: "Elevation")
//        HoverableChart(graph: powerGraph, xPosition: $xPosition, color: .purple, valueModifier: ConversionUtils.round, label: "Power")
//        HoverableChart(graph: strideLengthGraph, xPosition: $xPosition, color: .yellow, valueModifier: ConversionUtils.round, label: "Stride Length")
//        HoverableChart(graph: verticalOscillation, xPosition: $xPosition, color: .pink, valueModifier: ConversionUtils.round, label: "Vertical Oscillation")

                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.pace, color: .blue, label: "Pace", valueModifier: ConversionUtils.convertMpsToMpm)
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.cadence, color: .red, label: "Cadence")
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.elevation, color: .green, label: "Elevation")
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.power, color: .purple, label: "Power")
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.strideLength, color: .yellow, label: "Stride Length")
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.verticalOscillation, color: .pink, label: "Vertical Oscillation")
            } else {
                LineGraph(data: graphData.pace, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
                LineGraph(data: graphData.cadence, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: CadenceLineGraphStyle())
                LineGraph(data: graphData.elevation, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: ElevationLineGraphStyle())
                LineGraph(data: graphData.heartRate, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: HeartRateLineGraphStyle())
                LineGraph(data: graphData.power, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: PowerLineGraphStyle())
                LineGraph(data: graphData.strideLength, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: StrideLengthLineGraphStyle())
                LineGraph(data: graphData.verticalOscillation, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: VerticalOscillationLineGraphStyle())
            }
        }
    }
}
