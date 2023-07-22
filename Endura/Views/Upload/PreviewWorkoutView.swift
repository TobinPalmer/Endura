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
    @ObservedObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()

    init(workout: HKWorkout) {
        self.workout = workout
        Task {
//            async let data = try WorkoutUtils.workoutToEnduraWorkout(workout)
//            let _ = try await Firestore.firestore().collection("activities").addDocument(from: data)
        }
    }

    public var body: some View {
        let workoutDuration = workout.duration
        let workoutDistance = workout.totalDistance?.doubleValue(for: .meter())
        let workoutDurationFormatted = TimeUtils.secondsToFormattedTime(seconds: Int(workoutDuration))

        VStack {
            Text("Preview Workout")
            Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")
            let array = previewWorkoutModel.heartRateGraph
            let flattenedArry = array.flatMap {
                $0
            }

            let dates = flattenedArry.map {
                $0.0
            }

            let values = flattenedArry.map {
                $0.1
            }

            let heartRateData: HeartRateGraphData = Array(zip(dates, values.map {
                $0.0
            }))

            let rawPaceData = previewWorkoutModel.paceGraph
            let paceData = rawPaceData.map {
                $0.speed
            }

            var paceGraph: PaceGraphData {
                Array(zip(Array(0..<paceData.count), paceData))
            }

            let smoothPaceGraph: PaceGraphData = paceGraph.map { (index, value) in
                (index, value.rounded(toPlaces: 2))
            }

            ActivityMap(workout: workout)

            Chart(smoothPaceGraph, id: \.0) { tuple in
                LineMark(
                    x: .value("X values", tuple.0),
                    y: .value("Y values", tuple.1)
                )
            }

            Chart(heartRateData, id: \.0) { tuple in
                LineMark(
                    x: .value("X values", tuple.0),
                    y: .value("Y values", tuple.1)
                )
            }
        }
            .task {
                do {
                    async let _: () = try previewWorkoutModel.getHeartRateGraph(for: workout)
                    async let _: () = try previewWorkoutModel.getPaceGraph(for: workout)
                } catch WorkoutErrors.noWorkout {
                    print("No workout to get heart rate graph")
                } catch {
                    print("Error getting heart rate graph")
                }
            }
    }
}
