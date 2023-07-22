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

fileprivate enum WorkoutErrors: Error {
    case noWorkout
}

@MainActor
fileprivate final class PreviewWorkoutModel: ObservableObject {
    @Published final private var locations: [CLLocation] = []
    @Published final fileprivate var heartRateGraph: [HeartRateGraph] = []
    @Published final fileprivate var paceGraph: PaceGraph = []

    final fileprivate func getPaceGraph(for workout: HKWorkout) async throws -> () {
        do {
            let routes = try await HealthKitUtils.getWorkoutRoute(workout: workout)
            for route in routes {
                let graph = try await HealthKitUtils.getLocationData(for: route)
                paceGraph.append(contentsOf: graph)
            }
        } catch {
            heartRateGraph = []
            throw WorkoutErrors.noWorkout
        }
    }

    final fileprivate func getEnduraWorkout(_ workout: HKWorkout) async throws -> EnduraWorkout {
        do {
            return try await WorkoutUtils.workoutToEnduraWorkout(workout)
        } catch {
            throw error
        }
    }

    final fileprivate func getHeartRateGraph(for workout: HKWorkout) async throws -> () {
        do {
            let graph = try await HealthKitUtils.getHeartRateGraph(for: workout)
            heartRateGraph = graph
        } catch {
            heartRateGraph = []
            throw WorkoutErrors.noWorkout
        }
    }
}

public struct PreviewWorkoutView: View {
    private var workout: HKWorkout
    @State private var enduraWorkout: EnduraWorkout?
    @ObservedObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()

    init(workout: HKWorkout) {
        self.workout = workout
        Task {
//            async let data = try WorkoutUtils.workoutToEnduraWorkout(workout)
//            let _ = try await Firestore.firestore().collection("activities").addDocument(from: data)
        }
    }

    public var body: some View {
        VStack {
            Text("Preview")
            if let enduraWorkout = enduraWorkout {
                Text("\(enduraWorkout.duration) \(enduraWorkout.distance)")
                let heartRateTuple = enduraWorkout.heartRate.map { val in
                    (val.index, val.heartRate)
                }
                let paceTuple = enduraWorkout.location.map { val in
                    (val.index, val.speed)
                }

                if !heartRateTuple.isEmpty {
                    Chart(heartRateTuple, id: \.0) { tuple in
                        LineMark(
                            x: .value("X values", tuple.0),
                            y: .value("Y values", tuple.1)
                        )
                    }
                } else {
                    Text("No heart rate data available")
                }

                if !paceTuple.isEmpty {
                    Chart(paceTuple, id: \.0) { tuple in
                        LineMark(
                            x: .value("X values", tuple.0),
                            y: .value("Y values", tuple.1)
                        )
                    }
                } else {
                    Text("No pace data available")
                }

                if !enduraWorkout.location.isEmpty {
                    ActivityMap(enduraWorkout)
                } else {
                    Text("No route data available")
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
