import Foundation
import SwiftUI

#if canImport(Charts)
    import Charts
#endif

@available(iOS 16.0, *)
public struct HoverableChart: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel

    private let graph: IndexedLineGraphData
    private let minY: Double
    private let maxY: Double
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

        minY = graph.map { $0.1 }.min() ?? 0
        maxY = graph.map { $0.1 }.max() ?? 1
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
                    Gradient.Stop(color: color, location: 0),
                    Gradient.Stop(color: color.opacity(0.5), location: 1),
                ], startPoint: .bottom, endPoint: .top)).mask {
                    var data: [(Date, Double)] = []
                    var lastTimestamp: Date? = nil
                    let _ = graph.sorted(by: { $0.0 < $1.0 }).map { point in
                        if let lastTimestamp = lastTimestamp,
                           point.0.timeIntervalSince(lastTimestamp) > Double(activityViewModel.interval)
                        {
                            data.append((lastTimestamp.addingTimeInterval(1), 0))
                            data.append((point.0.addingTimeInterval(-1), 0))
                        }
                        data.append((point.0, point.1))
                        lastTimestamp = point.0
                    }

                    ForEach(data, id: \.0) { point in
                        AreaMark(
                            x: .value("Timestamp", point.0),
                            y: .value("Value", point.1)
                        )
                        .foregroundStyle(.red)
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
            .chartXAxis(.hidden)
            .chartXScale(domain: workoutStart ... workoutEnd)
            .chartYScale(domain: (minY - (maxY - minY) * 0.1) ... (maxY + (maxY - minY) * 0.1))
            .chartOverlay { (chartProxy: ChartProxy) in
                ZStack {
                    if let analysisPosition = activityViewModel.analysisPosition {
                        let value = activityViewModel.getAnalysisValue(for: analysisPosition, graph: graph)
                        let chartSize = chartProxy.plotAreaSize
                        let overlayWidth = 150.0
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
