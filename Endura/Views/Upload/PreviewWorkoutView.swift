//
// Created by Tobin Palmer on 7/21/23.
//

import Foundation
import SwiftUI
import HealthKit
import MapKit
import Charts

fileprivate enum Errors: Error {
    case noWorkout
}

fileprivate final class PreviewWorkoutModel: ObservableObject {
    @Published final private var locations: [CLLocation] = []
    @Published final fileprivate var heartRateGraph: [HeartRateGraph] = []
    @Published final fileprivate var paceGraph: [CLLocation] = []

    final fileprivate func getPaceGraph(for workout: HKWorkout) async throws -> () {
        do {
            let routes = try await HealthKitUtils.getWorkoutRoute(workout: workout)
            for route in routes {
                let graph = try await HealthKitUtils.getLocationData(for: route)
                paceGraph.append(contentsOf: graph)
            }
        } catch {
            heartRateGraph = []
            throw Errors.noWorkout
        }
    }

    final fileprivate func getHeartRateGraph(for workout: HKWorkout) async throws -> () {
        do {
            let graph = try await HealthKitUtils.getHeartRateGraph(for: workout)
            heartRateGraph = graph
        } catch {
            heartRateGraph = []
            throw Errors.noWorkout
        }
    }
}

public struct PreviewWorkoutView: View {
    private var workout: HKWorkout
    @ObservedObject fileprivate var previewWorkoutModel = PreviewWorkoutModel()

    init(workout: HKWorkout) {
        self.workout = workout
    }

    public var body: some View {
        let workoutDuration = workout.duration
        let workoutDistance = workout.totalDistance?.doubleValue(for: .meter())
        let workoutDurationFormatted = TimeUtils.secondsToFormattedTime(seconds: Int(workoutDuration))

        VStack {
            Text("Preview Workout")
            Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")
            let array = previewWorkoutModel.heartRateGraph
            let _ = print(array)
            let flattenedArry = array.flatMap {
                $0
            }

            let dates = flattenedArry.map {
                $0.0
            }

            let values = flattenedArry.map {
                $0.1
            }

            let heartRateData = Array(zip(dates, values.map {
                $0.0
            }))

            let rawPaceData = previewWorkoutModel.paceGraph
            let paceData = rawPaceData.map {
                $0.speed
            }

            var paceGraph: [(Int, Double)] {
                Array(zip(Array(0..<paceData.count), paceData))
            }

            let smoothPaceGraph: [(Int, Double)] = paceGraph.map { (index, value) in
                (index, value.rounded(toPlaces: 2))
            }

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
                } catch Errors.noWorkout {
                    print("No workout to get heart rate graph")
                } catch {
                    print("Error getting heart rate graph")
                }
            }
    }
}
