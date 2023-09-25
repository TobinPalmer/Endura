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

            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.pace,
                color: .blue,
                label: "Pace",
                valueModifier: ConversionUtils.convertMpsToMpm
            )
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.heartRate,
                color: .red,
                label: "Heart Rate"
            )
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.elevation,
                color: .gray,
                label: "Elevation"
            )
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.cadence,
                color: .cyan,
                label: "Cadence"
            )
            HoverableChart(workoutStart: start, workoutEnd: end, graph: graphData.power, color: .purple, label: "Power")
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.strideLength,
                color: .yellow,
                label: "Stride Length",
                valueModifier: ConversionUtils.round2
            )
            HoverableChart(
                workoutStart: start,
                workoutEnd: end,
                graph: graphData.verticalOscillation,
                color: .pink,
                label: "Vertical Oscillation",
                valueModifier: ConversionUtils.round2
            )
        }
    }
}
