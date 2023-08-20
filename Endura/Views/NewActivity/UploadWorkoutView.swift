//
//  UploadWorkoutView.swift created on 8/20/23.
//

import Charts
import FirebaseCore
import FirebaseFirestore
import Foundation
import HealthKit
import MapKit
import SwiftUI
import SwiftUICharts

@MainActor private final class PreviewWorkoutModel: ObservableObject {
    @Published fileprivate var mapRef: (any View)?
    @Published fileprivate var geometryRef: GeometryProxy?

    fileprivate final func getEnduraWorkout(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
        do {
            return try await HealthKitUtils.workoutToActivityDataWithRoute(workout)
        } catch {
            throw error
        }
    }
}

struct PreviewWorkoutView: View {
    @StateObject var activityViewModel = ActivityViewModel()

    private var workout: HKWorkout
    @State private var enduraWorkout: ActivityDataWithRoute?
    @State private var workoutStats: ActivityGridStatsData?
    @State private var workoutHeader: ActivityHeaderData?
    @ObservedObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()

    init(workout: HKWorkout) {
        self.workout = workout
    }

    private func assignMap(map: (any View)?, geometry: GeometryProxy?) {
        previewWorkoutModel.mapRef = map
        previewWorkoutModel.geometryRef = geometry
    }

    var body: some View {
        VStack {
            ScrollView {
                if let workoutHeader {
                    ActivityHeader(uid: workoutHeader.uid, activityData: workoutHeader)
                } else {
                    ActivityHeader(uid: "", activityData: nil, placeholder: true)
                }

                if let activityData = enduraWorkout {
                    if !activityData.data.routeData.isEmpty {
                        VStack {
                            GeometryReader { geometry in
                                let map =
                                    ActivityMap(activityData.data.routeData)
                                        .frame(height: 300)
                                        .environmentObject(activityViewModel)
                                VStack {
                                    map
                                }
                                .onAppear {
                                    print("Assigning Map")
                                    assignMap(map: map, geometry: geometry)
                                }
                            }
                        }
                        .frame(height: 300)
                    }
                } else {
                    VStack {
                        Text("Loading...")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: 300)
                    .foregroundColor(Color.red)
                    .border(.red)
                }

                if let activityData = enduraWorkout {
                    ActivityGridStats(activityData: workoutStats, topSpace: !activityData.data.routeData.isEmpty)
                } else {
                    ActivityGridStats(activityData: workoutStats, topSpace: false)
                }

                if let activityData = enduraWorkout {
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
                    .environmentObject(activityViewModel)

                    Button {
                        Task {
                            do {
                                if let mapRef = previewWorkoutModel.mapRef, let geometryRef = previewWorkoutModel.geometryRef {
                                    print("Uploading with map")
                                    try await ActivityUtils.uploadActivity(activity: activityData, image: mapRef.takeScreenshot(origin: geometryRef.frame(in: .global).origin, size: geometryRef.size))
                                } else {
                                    print("Uploading without map")
                                    try await ActivityUtils.uploadActivity(activity: activityData)
                                }
                            } catch {
                                print("Error uploading workout: \(error)")
                            }
                        }
                    } label: {
                        Text("Upload")
                    }
                    .buttonStyle(EnduraButtonStyle())
                }
            }
            .padding()
            .frame(maxHeight: .infinity)
            .task {
                do {
                    workoutStats = HealthKitUtils.getWorkoutGridStatsData(workout)
                    workoutHeader = try await HealthKitUtils.getWorkoutHeaderData(workout)
                    enduraWorkout = try await previewWorkoutModel.getEnduraWorkout(workout)
                } catch WorkoutErrors.noWorkout {
                    print("No workout to get heart rate graph")
                } catch let err {
                    print("Error getting graph data", err)
                }
            }
//      } else {
//        ScrollView {
//          ActivityHeader(uid: "", activityData: nil, placeholder: true)
//
//          VStack {
//            Text("Loading...")
//          }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .frame(height: 300)
//            .foregroundColor(Color.red)
//            .border(.red)
//
//          ActivityGridStats(activityData: nil, placeholder: true)
//        }
//      }
        }
    }
}
