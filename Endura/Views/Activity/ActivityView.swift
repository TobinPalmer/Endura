//
// Created by Brandon Kirbyson on 7/28/23.
//

import Foundation
import SwiftUI

struct ActivityView: View {
    @StateObject var activityViewModel = ActivityViewModel()
    @EnvironmentObject var databaseCache: DatabaseCacheModel

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
                    VStack {
                        ActivityHeader(uid: activity.uid)

                        ActivityMap(activityData.data.routeData)
                            .frame(height: 300)

                        ActivityGridStats(distance: activityData.distance, duration: activityData.duration, topSpace: !activityData.data.routeData.isEmpty)

                        VStack {
                            let (paceGraph, heartRateGraph) = activityData.getPaceAndHeartRateGraphData()
                            LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
                            LineGraph(data: heartRateGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: HeartRateLineGraphStyle())
                        }
                    }
                    .environmentObject(activityViewModel)
                    .padding()
                }
            }
        }
        .task {
            activityData = await activity.withRouteData(id: id)
        }
    }
}
