import FirebaseStorage
import Foundation
import HealthKit
import MapKit
import SwiftUI

@MainActor private final class PreviewWorkoutModel: ObservableObject {
    @Published fileprivate var mapRef: (any View)?
    @Published fileprivate var geometryRef: GeometryProxy?
    @Published fileprivate var enduraWorkout: ActivityDataWithRoute?
    @Published fileprivate var workoutStats: ActivityGridStatsData?
    @Published fileprivate var workoutHeader: ActivityHeaderData?
    @Published fileprivate var activityTitle: String = ""
    @Published fileprivate var activityDescription: String = ""

    fileprivate final func getEnduraWorkout(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
        do {
            return try await HealthKitUtils.workoutToActivityDataWithRoute(for: workout)
        } catch {
            throw error
        }
    }
}

struct PreviewWorkoutView: View {
    @StateObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()
    @State private var isShowingSummary = false

    @MainActor func updateWorkoutStats(_ workout: HKWorkout) {
        previewWorkoutModel.workoutStats = HealthKitUtils.getWorkoutGridStatsData(for: workout)
    }

    @MainActor func updateWorkoutHeader(_ workout: HKWorkout) async throws {
        previewWorkoutModel.workoutHeader = try await HealthKitUtils.getWorkoutHeaderData(for: workout)
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
                if let workoutHeader = previewWorkoutModel.workoutHeader {
                    ActivityHeader(uid: workoutHeader.uid, activityData: workoutHeader)
                } else {
                    ActivityHeader(uid: "", activityData: nil, placeholder: true)
                }

                TextField("Title", text: $previewWorkoutModel.activityTitle)
                    .font(.title)
                    .textFieldStyle(EnduraTextFieldStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                TextField("Description", text: $previewWorkoutModel.activityDescription)
                    .font(.body)
                    .textFieldStyle(EnduraTextFieldStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

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

                    VStack {
                        ActivityGraphsView(activityData).environmentObject(activityViewModel)
                    }

                    Button {
                        Task {
                            do {
                                let storage = Storage.storage()

                                if let mapRef = previewWorkoutModel.mapRef, let geometryRef = previewWorkoutModel.geometryRef {
                                    if previewWorkoutModel.activityTitle.isEmpty {
                                        activityData.title = ConversionUtils.getDefaultActivityName(time: activityData.time)
                                    } else {
                                        activityData.title = previewWorkoutModel.activityTitle
                                        activityData.description = previewWorkoutModel.activityDescription
                                    }

                                    try ActivityUtils.uploadActivity(activity: activityData, image: mapRef.takeScreenshot(origin: geometryRef.frame(in: .global).origin, size: geometryRef.size), storage: storage)
                                } else {
                                    try ActivityUtils.uploadActivity(activity: activityData)
                                }

                                ActivityUtils.setActivityUploaded(for: workout)
                                isShowingSummary = true
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
                    try await updateWorkoutHeader(workout)
                }
                group.addTask {
                    try await updateEnduraWorkout(workout)
                }
            }

//        .fullScreenCover(isPresented: Binding(
//          get: { previewWorkoutModel.isShowingSummary || isShowingSummary },
//          set: { newValue in
//            previewWorkoutModel.isShowingSummary = newValue
//            isShowingSummary = newValue
//          }
//        )) {
//          if let activityData = previewWorkoutModel.enduraWorkout {
//            PostUploadView(activityData: activityData)
//          }
//        }
        }
        .fullScreenCover(isPresented: $isShowingSummary) {
            if let activityData = previewWorkoutModel.enduraWorkout {
//          PostUploadView(activityData: activityData)
            } else {
                Text("Error uploading workout")
            }
        }
    }
}
