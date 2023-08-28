import Foundation
import HealthKit
import MapKit
import SwiftUI

@MainActor private final class PreviewWorkoutModel2: ObservableObject {
    @Published fileprivate var mapRef: (any View)?
    @Published fileprivate var geometryRef: GeometryProxy?
    @Published fileprivate var enduraWorkout: ActivityDataWithRoute?
    @Published fileprivate var workoutStats: ActivityGridStatsData?

    fileprivate final func getEnduraWorkout(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
        do {
            return try await HealthKitUtils.workoutToActivityDataWithRoute(for: workout)
        } catch {
            throw error
        }
    }
}

struct PreviewWorkoutView2: View {
    @StateObject fileprivate var previewWorkoutModel = PreviewWorkoutModel2()
    @State private var isShowingSummary = false

    @MainActor func updateWorkoutStats(_ workout: HKWorkout) {
        previewWorkoutModel.workoutStats = HealthKitUtils.getWorkoutGridStatsData(for: workout)
    }

    @MainActor func updateEnduraWorkout(_ workout: HKWorkout) async throws {
        previewWorkoutModel.enduraWorkout = try await previewWorkoutModel.getEnduraWorkout(workout)
    }

    private var workout: HKWorkout

    init(workout: HKWorkout) {
        self.workout = workout
    }

    var body: some View {
        VStack {
            ScrollView {
                if var activityData = previewWorkoutModel.enduraWorkout {
                    let activityViewModel = ActivityViewModel(activityData: activityData.getIndexedGraphData(), routeLocationData: activityData.getIndexedRouteLocationData(), interval: activityData.data.graphInterval)

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
                                    previewWorkoutModel.mapRef = map
                                    previewWorkoutModel.geometryRef = geometry
                                }
                            }
                        }
                        .frame(height: 300)
                    }

                    ActivityGridStats(activityData: previewWorkoutModel.workoutStats, topSpace: !activityData.data.routeData.isEmpty)

                    Button {
                        Task {
                            do {
                                if let mapRef = previewWorkoutModel.mapRef, let geometryRef = previewWorkoutModel.geometryRef {
                                    activityData.title = ConversionUtils.getDefaultActivityName(time: activityData.time)

//                  try ActivityUtils.uploadActivity(activity: activityData, image: mapRef.takeScreenshot(origin: geometryRef.frame(in: .global).origin, size: geometryRef.size))
                                } else {
//                  try ActivityUtils.uploadActivity(activity: activityData)
                                }

                                ActivityUtils.setActivityUploaded(workout)
                                isShowingSummary = true
                                return;
                                print("setting model to true")
                            } catch {
                                print("Error uploading workout: \(error)")
                            }
                        }
                    } label: {
                        Text("Upload")
                    }
                    .buttonStyle(EnduraButtonStyle())
                } else {
                    LoadingMap()
                    ActivityGridStats(activityData: previewWorkoutModel.workoutStats, topSpace: false)
                }
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
        .task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    await updateWorkoutStats(workout)
                }
                group.addTask {
                    try await updateEnduraWorkout(workout)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingSummary) {
            if let activityData = previewWorkoutModel.enduraWorkout {
                PostUploadView(activityData: activityData, mapRef: $previewWorkoutModel.mapRef, geometryRef: $previewWorkoutModel.geometryRef)
            } else {
                Text("Error uploading workout")
            }
        }
    }
}
