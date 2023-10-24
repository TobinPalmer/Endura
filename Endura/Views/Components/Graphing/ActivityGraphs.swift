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
            let start = activityData.time
            let end = activityData.time.addingTimeInterval(activityData.totalDuration)

            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.pace,
                color: .blue,
                label: "Pace",
                valueSuffix: " /mi",
                valueModifier: ConversionUtils.convertMpsToMpm
            )
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.heartRate,
                color: .red,
                label: "Heart Rate",
                valueSuffix: " bpm",
                valueModifier: ConversionUtils.round
            )
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.elevation,
                color: .gray,
                label: "Elevation",
                valueSuffix: " ft",
                valueModifier: ConversionUtils.round
            )
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.cadence,
                color: .cyan,
                label: "Cadence",
                valueSuffix: " spm",
                valueModifier: ConversionUtils.round
            )
            HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.power, color: .purple, label: "Power",
                           valueSuffix: " W", valueModifier: ConversionUtils.round)
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.strideLength,
                color: .yellow,
                label: "Stride Length",
                valueSuffix: " m",
                valueModifier: ConversionUtils.round2
            )
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.verticalOscillation,
                color: .pink,
                label: "Vertical Oscillation",
                valueSuffix: " cm",
                valueModifier: ConversionUtils.round2
            )
        }
    }
}
