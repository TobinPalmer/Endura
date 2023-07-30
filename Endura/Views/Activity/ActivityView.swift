//
// Created by Brandon Kirbyson on 7/28/23.
//

import Foundation
import SwiftUI

public class ActivityViewModel: ObservableObject {
    @Published var analysisPosition: Date? = nil
}

public struct ActivityView: View {
    @StateObject var viewModel = ActivityViewModel()

    private var id: String
    private var activity: ActivityData
    @State var activityData: ActivityDataWithRoute?

    public init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    public var body: some View {
        VStack {
            if let activityData = activityData {
                VStack {
                    HStack {
                        Text("\(ConversionUtils.metersToMiles(activityData.distance))")
                        Text("\(FormattingUtils.secondsToFormattedTime(activityData.duration))")
                    }

                    ActivityMap(activityData.data.routeData)
                            .frame(height: 300)
                            .environmentObject(viewModel)

                    let (paceGraph, heartRateGraph) = activityData.getPaceAndHeartRateGraphData()
                    if (!paceGraph.isEmpty) {
                        LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm)
                                .environmentObject(viewModel)
                    } else {
                        Text("No pace data available")
                    }
                    if (!heartRateGraph.isEmpty) {
                        LineGraph(data: heartRateGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round)
                                .environmentObject(viewModel)
                    } else {
                        Text("No heart rate data available")
                    }
                }
            }
        }
                .task {
                    activityData = await activity.withRouteData(id: id)
                }
    }

}
