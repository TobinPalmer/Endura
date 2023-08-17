//
// Created by Tobin Palmer on 7/21/23.
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
    @Published public var number = 2

    fileprivate final func getEnduraWorkout(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
        do {
            return try await HealthKitUtils.workoutToActivityData(workout)
        } catch {
            throw error
        }
    }
}

struct PreviewWorkoutView: View {
    @StateObject var activityViewModel = ActivityViewModel()

    private var workout: HKWorkout
    @State private var enduraWorkout: ActivityDataWithRoute?
    @ObservedObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()

    @State private var mapRef: (any View)? = nil
    @State private var geometryRef: GeometryProxy? = nil

    init(workout: HKWorkout) {
        self.workout = workout
    }

    var body: some View {
        VStack {
            if let activityData = enduraWorkout {
                ScrollView {
                    ActivityHeader(uid: activityData.uid, activityData: ActivityDataWithRoute.getDataWithoutRoute(activityData)())

                    if !activityData.data.routeData.isEmpty {
                        VStack {
                            GeometryReader { geometry in
                                VStack {
                                    let map =
                                        ActivityMap(activityData.data.routeData)
                                            .frame(height: 300)
                                            .environmentObject(activityViewModel)
                                    map

                                    let _ = mapRef = map
                                    let _ = geometryRef = geometry
                                }
                            }
                        }
                        .frame(height: 300)
                    }

                    VStack {
                        let paceGraph = activityData.getPaceGraph()
                        let heartRateGraph = activityData.getHeartRateGraph()
                        ActivityGridStats(activityData: ActivityDataWithRoute.getDataWithoutRoute(activityData)(), topSpace: !activityData.data.routeData.isEmpty)
                        LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm, style: PaceLineGraphStyle())
                        LineGraph(data: heartRateGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round, style: HeartRateLineGraphStyle())
                    }
                    .environmentObject(activityViewModel)

                    Button {
                        Task {
                            do {
                                if let mapRef = mapRef, let geometryRef = geometryRef {
                                    try await ActivityUtils.uploadActivity(activity: activityData, image: mapRef.takeScreenshot(origin: geometryRef.frame(in: .global).origin, size: geometryRef.size))
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
            } else {
                ProgressView {
                    Text("Loading...")
                }
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
        .task {
            do {
                enduraWorkout = try await previewWorkoutModel.getEnduraWorkout(workout)
            } catch WorkoutErrors.noWorkout {
                print("No workout to get heart rate graph")
            } catch {
                print("Error getting heart rate graph")
            }
        }
    }
}
