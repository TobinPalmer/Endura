//
// Created by Tobin Palmer on 7/21/23.
//

import Foundation
import SwiftUI
import HealthKit
import MapKit

fileprivate final class PreviewWorkoutModel: ObservableObject {
    @Published final private var locations: [CLLocation] = []
    @Published final fileprivate var heartRateGraph: [HeartRateGraph] = []

    final fileprivate func getHeartRateGraph(for workout: HKWorkout) async throws -> () {
        do {
            let graph = try await HealthKitUtils.getHeartRateGraph(for: workout)
//            self.heartRateGraph = graph.compactMap({ $0 })
//            return graph.compactMap({ $0 })
            print("got graph \(graph)")
            heartRateGraph = graph
        } catch {
            throw error
//            print("Error getting heart rate graph")
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
//        let _ = HealthKitUtils.getWorkoutRoute(workout: workout) { routes, error in
//            guard error == nil else {
//                print("Error getting route", String(describing: error))
//                return
//            }
//
//            guard let routes = routes else {
//                print("No routes")
//                return
//            }
//
//            print("Getting locations")
//            Task {
//                routes.forEach({ route in
//                    Task {
//                        do {
//                            let locations = try await HealthKitUtils.getLocationData(for: route)
//                            locations.forEach({ location in
//                                print(TimeUtils.convertMpsToMpm(metersPerSec: location.speed))
//                            })
//                        } catch {
//                            print("Error getting locations")
//                        }
//                    }
//                })
//            }
//        }

        let workoutDuration = workout.duration
        let workoutDistance = workout.totalDistance?.doubleValue(for: .meter())
        let workoutDurationFormatted = TimeUtils.secondsToFormattedTime(seconds: Int(workoutDuration))

//        let flattened = graph.compactMap {
//            $0
//        }

        VStack {
            Text("Preview Workout")
            Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")
            Text(String(describing: previewWorkoutModel.heartRateGraph))
//            List(flattened, id: \.0) { item in
//                Text("\(item.0) \(String(describing: item.1))")
//            }
        }
            .task {
                do {
                    try await previewWorkoutModel.getHeartRateGraph(for: workout)
                } catch {
                    print("Error getting heart rate graph")
                }
            }
//            .task {
//                await getLocations()
//            }
    }
}
