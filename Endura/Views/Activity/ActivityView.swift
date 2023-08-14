//
// Created by Brandon Kirbyson on 7/28/23.
//

import Foundation
import SwiftUI

struct ActivityView: View {
    @StateObject var activityViewModel = ActivityViewModel()

    private var id: String
    private var activity: ActivityData
    @State var activityData: ActivityDataWithRoute?

    public init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    var body: some View {
        VStack {
            if let activityData = activityData {
                ScrollView(.vertical) {
                    HStack {
                        Text("\(ConversionUtils.metersToMiles(activityData.distance))")
                        Text("\(FormattingUtils.secondsToFormattedTime(activityData.duration))")
                    }

                    ActivityMap(activityData.data.routeData)
                        .frame(height: 300)
                        .environmentObject(activityViewModel)

                    VStack {
                        let (paceGraph, heartRateGraph) = activityData.getPaceAndHeartRateGraphData()
                        if !paceGraph.isEmpty {
                            LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
                                .environmentObject(activityViewModel)
                        } else {
                            Text("No pace data available")
                        }
                        if !heartRateGraph.isEmpty {
                            LineGraph(data: heartRateGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: HeartRateLineGraphStyle())
                                .environmentObject(activityViewModel)
                        } else {
                            Text("No heart rate data available")
                        }
                    }
                }
            }
        }
        .task {
            activityData = await activity.withRouteData(id: id)
        }
    }
}
