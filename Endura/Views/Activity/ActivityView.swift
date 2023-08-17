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
                        ActivityHeader(uid: activity.uid, activityData: ActivityDataWithRoute.getDataWithoutRoute(activityData)())

                        ActivityMap(activityData.data.routeData)
                            .frame(height: 300)

                        ActivityGridStats(activityData: ActivityDataWithRoute.getDataWithoutRoute(activityData)(), topSpace: !activityData.data.routeData.isEmpty)

                        VStack {
                            let paceGraph = activityData.getPaceGraph()
                            let heartRateGraph = activityData.getHeartRateGraph()
                            let elevationGraph = activityData.getElevationGraph()

                            LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
                            LineGraph(data: heartRateGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: HeartRateLineGraphStyle())
                            LineGraph(data: elevationGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: AltitudeLineGraphStyle())
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
