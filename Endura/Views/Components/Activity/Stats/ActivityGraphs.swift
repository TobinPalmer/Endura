import Charts
import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct HoverableChart: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel

    private let graph: IndexedLineGraphData
    private let color: Color
    private let label: String
    private let valueModifier: (Double) -> String
    private let workoutStart: Date
    private let workoutEnd: Date

    public init(workoutStart: Date, workoutEnd: Date, graph: IndexedLineGraphData, color: Color, label: String, valueModifier: @escaping (Double) -> String = {
        ConversionUtils.round($0)
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
                RectangleMark(
                    xStart: .value("Timestamp", workoutStart),
                    xEnd: .value("Timestamp", workoutEnd)
                )
                    .foregroundStyle(.linearGradient(stops: [
                        Gradient.Stop(color: color.opacity(0.5), location: 0),
                        Gradient.Stop(color: color, location: 2 / 4)
                    ], startPoint: .bottom, endPoint: .top)).mask {


                        var lastTimestamp: Date? = nil
                        let sortedGraph = graph.sorted(by: { $0.0 < $1.0 })

                        let lineMarks = sortedGraph.map { tuple -> [AreaMark] in
                            var lineMarks: [AreaMark] = []

                            if let lastTimestamp = lastTimestamp,
                               tuple.0.timeIntervalSince(lastTimestamp) > Double(activityViewModel.interval) {
                                lineMarks.append(AreaMark(
                                    x: .value("Timestamp", lastTimestamp.addingTimeInterval(1)),
                                    y: .value("Value", 0)
                                ))

                                lineMarks.append(AreaMark(
                                    x: .value("Timestamp", tuple.0.addingTimeInterval(-1)),
                                    y: .value("Value", 0)
                                ))
//                            .foregroundStyle(color).interpolationMethod(.catmullRom) as! LineMark)
                            }

                            lineMarks.append(AreaMark(
                                x: .value("Timestamp", tuple.0),
                                y: .value("Value", tuple.1)
                            ))
//                        .foregroundStyle(color).interpolationMethod(.catmullRom) as! LineMark)

                            lastTimestamp = tuple.0

                            return lineMarks
                        }

                        let flattenedLineMarks: [AreaMark] = lineMarks.flatMap {
                            $0
                        }

                        ForEach(flattenedLineMarks.indices, id: \.self) { index in
                            flattenedLineMarks[index].foregroundStyle(color)
//                        .interpolationMethod(.catmullRom)
                        }

//                var lastTimestamp: Date? = nil
//                ForEach(graph.sorted(by: { $0.0 < $1.0 }), id: \.key) { tuple in
//                    if let lastTimestamp = lastTimestamp {
//                        if tuple.0.timeIntervalSince(lastTimestamp) > Double(activityViewModel.interval / 2) {
//                            LineMark(
//                                x: .value("Timestamp", lastTimestamp.addingTimeInterval(1)),
//                                y: .value("Value", 0)
//                            )
//                                .foregroundStyle(color).interpolationMethod(.catmullRom)
//
//                            LineMark(
//                                x: .value("Timestamp", tuple.0.addingTimeInterval(-1)),
//                                y: .value("Value", 0)
//                            )
//                                .foregroundStyle(color).interpolationMethod(.catmullRom)
//                        }
//                    }
//                    LineMark(
//                        x: .value("Timestamp", tuple.0),
//                        y: .value("Value", tuple.1)
//                    ).foregroundStyle(color).interpolationMethod(.catmullRom)
//                    lastTimestamp = tuple.0
//                }

                    }

                if let analysisPosition = activityViewModel.analysisPosition {
                    if let value = activityViewModel.getAnalysisValue(for: analysisPosition, graph: graph) {
                        PointMark(
                            x: .value("Timestamp", analysisPosition),
                            y: .value("Value", value)
                        )
                            .foregroundStyle(color)
                    }
                    RectangleMark(x: .value("Timestamp", analysisPosition), width: 1)
                        .foregroundStyle(color)
                        .annotation(
                            position: .top,
                            alignment: .center,
                            spacing: 0
                        ) {
                            let value = activityViewModel.getAnalysisValue(for: analysisPosition, graph: graph)
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
            let graphData = activityData.getGraphData()
            let start = activityData.workoutStart
            let end = activityData.workoutStart + activityData.duration

            if #available(iOS 16.0, *) {
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.pace, color: .blue, label: "Pace", valueModifier: ConversionUtils.convertMpsToMpm)
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.cadence, color: .red, label: "Cadence")
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.elevation, color: .green, label: "Elevation")
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.power, color: .purple, label: "Power")
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.strideLength, color: .yellow, label: "Stride Length", valueModifier: ConversionUtils.round2)
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.verticalOscillation, color: .pink, label: "Vertical Oscillation", valueModifier: ConversionUtils.round2)
            } else {
//                LineGraph(data: graphData.pace, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
//                LineGraph(data: graphData.cadence, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: CadenceLineGraphStyle())
//                LineGraph(data: graphData.elevation, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: ElevationLineGraphStyle())
//                LineGraph(data: graphData.heartRate, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: HeartRateLineGraphStyle())
//                LineGraph(data: graphData.power, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: PowerLineGraphStyle())
//                LineGraph(data: graphData.strideLength, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: StrideLengthLineGraphStyle())
//                LineGraph(data: graphData.verticalOscillation, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: VerticalOscillationLineGraphStyle())
            }
        }
    }
}
