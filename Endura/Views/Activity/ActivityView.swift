//
//  ActivityView.swift created on 8/19/23.
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
                        ActivityHeader(uid: activity.uid, activityData: activityData.withHeaderStats())

                        ActivityMap(activityData.data.routeData)
                            .frame(height: 300)

                        ActivityGridStats(activityData: ActivityDataWithRoute.withGridStats(activityData)(), topSpace: !activityData.data.routeData.isEmpty)

                        VStack {
                            let cadenceGraph = activityData.getGraph(for: .cadence)
                            let elevationGraph = activityData.getGraph(for: .elevation)
                            let groundContactTimeGraph = activityData.getGraph(for: .groundContactTime)
                            let heartRateGraph = activityData.getGraph(for: .heartRate)
                            let paceGraph = activityData.getGraph(for: .pace)
                            let powerGraph = activityData.getGraph(for: .power)
                            let strideLengthGraph = activityData.getGraph(for: .strideLength)
                            let verticalOscillationGraph = activityData.getGraph(for: .verticleOscillation)

                            LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
                            LineGraph(data: heartRateGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: HeartRateLineGraphStyle())
                            LineGraph(data: elevationGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: ElevationLineGraphStyle())
                            LineGraph(data: cadenceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: CadenceLineGraphStyle())
                            LineGraph(data: powerGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: PowerLineGraphStyle())
                            LineGraph(data: groundContactTimeGraph, step: activityData.data.graphInterval, height: 200, style: GroundContactTimeLineGraphStyle())
                            LineGraph(data: strideLengthGraph, step: activityData.data.graphInterval, height: 200, style: StrideLengthLineGraphStyle())
                            LineGraph(data: verticalOscillationGraph, step: activityData.data.graphInterval, height: 200, style: VerticalOscillationLineGraphStyle())
                        }
                    }
                    .environmentObject(activityViewModel)
                }
            } else {
                ScrollView {
                    ActivityHeader(uid: "", activityData: nil, placeholder: true)

                    VStack {
                        Text("Loading...")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: 300)
                    .foregroundColor(Color.red)
                    .border(.red)

                    ActivityGridStats(activityData: nil, placeholder: true)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        print("Edit")
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(action: {
                        ActivityUtils.deleteActivity(id: id)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .padding()
        .task {
            activityData = await activity.withRouteData(id: id)
        }
    }
}
