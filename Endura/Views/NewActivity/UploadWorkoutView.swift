//
// Created by Tobin Palmer on 7/21/23.
//

import Foundation
import SwiftUI
import HealthKit
import MapKit
import Charts
import FirebaseFirestore
import FirebaseCore
import SwiftUICharts

@MainActor fileprivate final class PreviewWorkoutModel: ObservableObject {
    @Published public var number = 2

    final fileprivate func getEnduraWorkout(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
        do {
            return try await HealthKitUtils.workoutToActivityData(workout)
        } catch {
            throw error
        }
    }
}

public struct PreviewWorkoutView: View {
    @StateObject var activityViewModel = ActivityViewModel()

    private var workout: HKWorkout
    @State private var enduraWorkout: ActivityDataWithRoute?
    @ObservedObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()

    init(workout: HKWorkout) {
        self.workout = workout
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Afternoon Run").font(.title)
            if let activityData = enduraWorkout {
                Text("\(activityData.duration) \(activityData.distance)")
                VStack {
                    HStack {
                        Text("\(ConversionUtils.metersToMiles(activityData.distance))")
                        Text("\(FormattingUtils.secondsToFormattedTime(activityData.duration))")
                    }

                    ActivityMap(activityData.data.routeData)
                        .frame(height: 300)
                        .environmentObject(activityViewModel)

                    let (paceGraph, heartRateGraph) = activityData.getPaceAndHeartRateGraphData()
                    if (!paceGraph.isEmpty) {
                        LineGraph(data: paceGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm)
                            .environmentObject(activityViewModel)
                    } else {
                        Text("No pace data available")
                    }
                    if (!heartRateGraph.isEmpty) {
                        LineGraph(data: heartRateGraph, step: activityData.data.graphInterval, height: 200, valueModifier: ConversionUtils.round)
                            .environmentObject(activityViewModel)
                    } else {
                        Text("No heart rate data available")
                    }
                }

                Button {
                    Task {
                        do {
//                            try Firestore.firestore().collection("activities").addDocument(data: enduraWorkout)
                        } catch {
                            print("Error uploading workout: \(error)")
                        }
                    }
                } label: {
                    Text("Upload")
                }

            } else {
                ProgressView {
                    Text("Loading...")
                }
            }
        }
            .task {
                do {
                    enduraWorkout = try await previewWorkoutModel.getEnduraWorkout(workout)
                } catch WorkoutErrors.noWorkout {
                    print("No workout to get heart rate graph")
                } catch {
                    print("Error getting heart rate graph")
                }
            }
        //            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        //            .task {
        //                do {
        //                    enduraWorkout = try await previewWorkoutModel.getEnduraWorkout(workout)
        //                } catch WorkoutErrors.noWorkout {
        //                    print("No workout to get heart rate graph")
        //                } catch {
        //                    print("Error getting heart rate graph")
        //                }
        //            }
    }
}
