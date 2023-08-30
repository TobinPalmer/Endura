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
            let chartPadding = 10.0
            Chart {
                RectangleMark(
                    xStart: .value("Timestamp", workoutStart),
                    xEnd: .value("Timestamp", workoutEnd)
                )
                    .foregroundStyle(.linearGradient(stops: [
                        Gradient.Stop(color: color.opacity(0.5), location: 0),
                        Gradient.Stop(color: color, location: 2 / 4),
                    ], startPoint: .bottom, endPoint: .top)).mask {
                        var data: [(Date, Double)] = []
                        var lastTimestamp: Date? = nil
                        let _ = graph.sorted(by: { $0.0 < $1.0 }).map { point in
                            if let lastTimestamp = lastTimestamp,
                               point.0.timeIntervalSince(lastTimestamp) > Double(activityViewModel.interval) {
                                data.append((lastTimestamp.addingTimeInterval(1), 0))
                                data.append((point.0.addingTimeInterval(-1), 0))
                            }
                            data.append((point.0, point.1))
                            lastTimestamp = point.0
                        }

                        ForEach(data, id: \.0) { tuple in
                            AreaMark(
                                x: .value("Timestamp", tuple.0),
                                y: .value("Value", tuple.1)
                            )
                                .foregroundStyle(color)
                        }
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
                }
            }
                .frame(width: UIScreen.main.bounds.width - chartPadding * 2, height: 200)
                .chartOverlay { (chartProxy: ChartProxy) in
                    ZStack {
                        if let analysisPosition = activityViewModel.analysisPosition {
                            let value = activityViewModel.getAnalysisValue(for: analysisPosition, graph: graph)
                            let chartSize = chartProxy.plotAreaSize
                            let overlayWidth = 150.0;
                            let centerOffset = (UIScreen.main.bounds.width - chartPadding * 2) / 2
                            let xPosition = max(-centerOffset + overlayWidth / 2, min(centerOffset - overlayWidth / 2, (chartProxy.position(forX: analysisPosition) ?? 0) - centerOffset))

                            Text("\(value != nil ? valueModifier(value!) : "No Data")")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding()
                                .foregroundColor(.white)
                                .frame(width: overlayWidth, height: 50)
                                .background(color)
                                .cornerRadius(5)
                                .offset(x: xPosition, y: -chartSize.height / 2 - 25)

                        }
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
