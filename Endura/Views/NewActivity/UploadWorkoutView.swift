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
    final fileprivate func getEnduraWorkout(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
        do {
            return try await HealthKitUtils.workoutToActivityData(workout)
        } catch {
            throw error
        }
    }
}

public struct PreviewWorkoutView: View {
    private var workout: HKWorkout
    @State private var enduraWorkout: ActivityDataWithRoute?
    @ObservedObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()

    init(workout: HKWorkout) {
        self.workout = workout
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Afternoon Run").font(.title)
            if let enduraWorkout = enduraWorkout {
                Text("\(enduraWorkout.duration) \(enduraWorkout.distance)")

                ActivityMap(enduraWorkout.data.routeData)
                        .frame(height: 300)

                var heartRate = [(Date, Double)]()
                var pace = [(Date, Double)]()

                let _ = enduraWorkout.data.graphData.compactMap { val in
                    if (!val.heartRate.isNaN) {
                        heartRate.append((val.timestamp, val.heartRate))
                    }
                    if (!val.pace.isNaN) {
                        pace.append(((val.timestamp, val.pace)))
                    }
                }

                GeometryReader { geometry in
                    VStack {
                        VStack {
                            LineGraphGroup {
                                if (!pace.isEmpty) {
                                    LineGraph(data: pace, step: enduraWorkout.data.graphInterval, height: 200, valueModifier: ConversionUtils.convertMpsToMpm)
                                } else {
                                    Text("No pace data available")
                                }
                                if (!heartRate.isEmpty) {
                                    LineGraph(data: heartRate, step: enduraWorkout.data.graphInterval, height: 200)
                                } else {
                                    Text("No heart rate data available")
                                }
                            }
                                    .environmentObject(LineGraphViewModel())
                        }
                                .frame(width: geometry.size.width - 50, height: geometry.size.height)
                    }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                }

                Button {
                    Task {
                        do {
                            try Firestore.firestore().collection("activities").addDocument(from: enduraWorkout.getDataWithoutRoute()).collection("data").document("data").setData(from: enduraWorkout.data)
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
    }
}
