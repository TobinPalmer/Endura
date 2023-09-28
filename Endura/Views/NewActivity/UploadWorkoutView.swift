import Foundation
import HealthKit
import MapKit
import SwiftUI

@MainActor private final class UploadWorkoutViewModel: ObservableObject {
    @Published fileprivate var mapRef: (any View)?
    @Published fileprivate var geometryRef: GeometryProxy?
    @Published fileprivate var activityData: ActivityDataWithRoute?

    fileprivate final func getActivityData(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
        do {
            return try await HealthKitUtils.workoutToActivityDataWithRoute(for: workout)
        } catch {
            throw error
        }
    }
}

struct UploadWorkoutView: View {
    @StateObject fileprivate var viewModel = UploadWorkoutViewModel()
    @State private var isShowingSummary = false
    @State var activityTitle: String = ""
    @State var activityDescription: String = ""

    @MainActor func updateActivityData(_ workout: HKWorkout) async throws {
        viewModel.activityData = try await viewModel.getActivityData(workout)
    }

    private var workout: HKWorkout

    init(workout: HKWorkout) {
        self.workout = workout
    }

    var body: some View {
        VStack {
            ScrollView {
                if let activityData = viewModel.activityData {
                    ActivityHeader(uid: activityData.uid, activityData: activityData.getDataWithoutRoute())
                } else {
                    ActivityHeader(uid: "", activityData: nil, placeholder: true)
                }

                TextField("Title", text: $activityTitle)
                    .font(.title)
                    .textFieldStyle(EnduraTextFieldStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                TextField("Description", text: $activityDescription)
                    .font(.body)
                    .textFieldStyle(EnduraTextFieldStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                if var activityData = viewModel.activityData {
                    let activityViewModel = ActivityViewModel(
                        activityData: activityData.getIndexedGraphData(),
                        routeLocationData: activityData.getIndexedRouteLocationData(),
                        interval: activityData.data.graphInterval
                    )

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
                                    viewModel.mapRef = map
                                    viewModel.geometryRef = geometry
                                }
                            }
                        }
                        .frame(height: 300)
                    }

                    if let activityData = viewModel.activityData {
                        ActivityGridStats(
                            activityData: activityData.getDataWithoutRoute(),
                            topSpace: !activityData.data.routeData.isEmpty
                        )
                    } else {}

                    ActivitySplitGraph(splits: activityData.stats.splits)

                    VStack {
                        ActivityGraphsView(activityData).environmentObject(activityViewModel)
                    }

                    Button {
                        activityData.social.title = ConversionUtils.getDefaultActivityName(time: activityData.time)

                        ActivityUtils.setActivityUploaded(for: workout)
                        isShowingSummary = true

                    } label: {
                        Text("Upload")
                    }
                    .buttonStyle(EnduraButtonStyleOld())
                } else {
                    LoadingMap()
                    if let activityData = viewModel.activityData {
                        ActivityGridStats(
                            activityData: activityData.getDataWithoutRoute(),
                            topSpace: !activityData.data.routeData.isEmpty
                        )
                    } else {
                        ActivityGridStats(
                            activityData: nil,
                            topSpace: false,
                            placeholder: true
                        )
                    }
                }
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
        .task {
            do {
                try await updateActivityData(workout)
            } catch {
                print("Error getting activity data: \(error)")
            }
        }

        .fullScreenCover(isPresented: $isShowingSummary) {
            if let activityData = viewModel.activityData {
                PostUploadView(
                    activityData: activityData,
                    mapRef: $viewModel.mapRef,
                    geometryRef: $viewModel.geometryRef
                )
            } else {
                Text("Error uploading workout")
            }
        }
    }
}
