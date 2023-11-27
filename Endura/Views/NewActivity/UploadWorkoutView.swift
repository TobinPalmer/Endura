import FirebaseStorage
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
    @EnvironmentObject private var activeUser: ActiveUserModel
    @StateObject fileprivate var viewModel = UploadWorkoutViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingSummary = false
    @State var activityTitle: String = ""
    @State var activityDescription: String = ""

    @State private var uploading = false

    @MainActor func updateActivityData(_ workout: HKWorkout) async throws {
        viewModel.activityData = try await viewModel.getActivityData(workout)
        activityTitle = ConversionUtils.getDefaultActivityName(time: viewModel.activityData?.time ?? Date())
    }

    private var workout: HKWorkout

    init(workout: HKWorkout) {
        self.workout = workout
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    TextField("Title", text: $activityTitle)
                        .font(.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)

                    TextField("Description", text: $activityDescription)
                        .font(.body)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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

                        DisclosureGroup("Analysis Graphs") {
                            ActivityGraphsView(activityData).environmentObject(activityViewModel)
                        }

                        DisclosureGroup("Splits") {
                            ActivitySplitGraph(splits: activityData.stats.splits)
                        }

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
                .enduraPadding()
            }
            Button {
                if var activityData = viewModel.activityData {
                    if activityTitle.isEmpty {
                        activityData.social.title = ConversionUtils.getDefaultActivityName(time: activityData.time)
                    } else {
                        activityData.social.title = activityTitle
                    }
                    activityData.social.description = activityDescription
                    activityData.visibility = activeUser.settings.data.defaultActivityVisibility

                    viewModel.activityData = activityData

                    uploading = true
                    Task {
                        let storage = Storage.storage()

                        do {
                            if let mapRef = viewModel.mapRef, let geometryRef = viewModel.geometryRef {
                                let image = mapRef.takeScreenshot(
                                    origin: geometryRef.frame(in: .global).origin,
                                    size: geometryRef.size
                                )

                                try await ActivityUtils.uploadActivity(
                                    activity: activityData,
                                    image: image,
                                    storage: storage
                                )
                            } else {
                                try await ActivityUtils.uploadActivity(activity: activityData)
                            }

                            activeUser.training.processNewActivity(activityData)

                            ActivityUtils.setActivityUploaded(for: workout)
                            dismiss()
                        } catch {
                            Global.log.error("Error uploading activity: \(error)")
                        }
                    }
//                    isShowingSummary = true
                }
            } label: {
                if uploading {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Uploading...")
                    }
                } else {
                    if ActivityUtils.isActivityUploaded(workout) {
                        Text("Already Uploaded!")
                    } else {
                        Text("Upload")
                    }
                }
            }
            .buttonStyle(EnduraNewButtonStyle())
            .disabled(viewModel.activityData == nil || ActivityUtils.isActivityUploaded(workout))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .frame(height: 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
