import Foundation
import SwiftUI

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
            let end = activityData.workoutStart.addingTimeInterval(activityData.totalDuration)

            if #available(iOS 16.0, *) {
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.pace, color: .blue, label: "Pace", valueModifier: ConversionUtils.convertMpsToMpm)
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.heartRate, color: .red, label: "Heart Rate")
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.elevation, color: .gray, label: "Elevation")
                HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.cadence, color: .cyan, label: "Cadence")
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
