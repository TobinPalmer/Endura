//
//  Workout.swift
//  Endura
//
//  Created by Tobin Palmer on 7/18/23.
//

import HealthKit
import MapKit
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

fileprivate func aroundEqual(_ lhs: Double, _ rhs: Double) -> Bool {
    abs(lhs - rhs) < 0.1
}

// Endura workouts, not HealthKit workouts
public struct WorkoutUtils {
    public static func workoutToActivityData(_ workout: HKWorkout) async throws -> ActivityData {
        let workoutDistance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
        let workoutDuration = workout.duration
        var routeData = [RouteData]()

        let routes = try await HealthKitUtils.getWorkoutRoute(workout: workout)

        var heartRate = try await HealthKitUtils.getHeartRateGraph(for: workout)

        for route in routes {
            let data = try await HealthKitUtils.getLocationData(for: route)

            print(heartRate.count, data.count)
            for point in data {
                var heartRateAtPoint: Double?;

                for i in 0..<heartRate.count {
                    if Int(heartRate[i].0.timeIntervalSince1970) == Int(point.timestamp.timeIntervalSince1970) { // Check if dates are about equal
                        heartRateAtPoint = heartRate[i].1
                        heartRate.removeSubrange(0...i) // Remove all previous heart rate points since they are no longer needed
                        break;
                    }
                }

                let routePoint = RouteData(
                    timestamp: point.timestamp,
                    location: LocationData(
                        latitude: point.coordinate.latitude,
                        longitude: point.coordinate.longitude
                    ),
                    altitude: point.altitude,
                    heartRate: heartRateAtPoint ?? 0.0,
                    pace: point.speed
                )
                routeData.append(routePoint)
            }
        }

        let workoutData = ActivityData(
            uid: "test",
            time: workout.startDate,
            distance: workoutDistance,
            duration: workoutDuration,
            comments: [],
            likes: [],
            routeData: routeData
        )

        return workoutData

//            var rawPaceData: PaceGraph = []
//            let routes = try await HealthKitUtils.getWorkoutRoute(workout: workout)
//            for route in routes {
//                let graph = try await HealthKitUtils.getLocationData(for: route)
//                rawPaceData.append(contentsOf: graph)
//            }
//            let paceData = rawPaceData.map {
//                $0.speed
//            }
//
//            var paceGraph: PaceGraphData {
//                Array(zip(Array(0..<paceData.count), paceData))
//            }
//
//            let smoothPaceGraph: PaceGraphData = paceGraph.map { (index, value) in
//                (index, value.rounded(toPlaces: 2))
//            }
//
//            do {
//                async let heartRate = try HealthKitUtils.getHeartRateGraph(for: workout)
//                let flattenedArry = try await heartRate.flatMap {
//                    $0
//                }
//
//                let dates = flattenedArry.map {
//                    $0.0
//                }
//
//                let values = flattenedArry.map {
//                    $0.1
//                }
//
//                let heartRateGraph: HeartRateGraphData = Array(zip(dates, values.map {
//                    $0.0
//                }))
//
//                let startTime = workout.startDate
//
//                let finalPaceGraph: [PaceGraphDataEncodable] = smoothPaceGraph.map {
//                    PaceGraphDataEncodable(tuple: $0)
//                }
//
//                let finalHeartRateGraph: [HeartRateGraphDataEncodable] = heartRateGraph.map {
//                    HeartRateGraphDataEncodable(tuple: $0)
//                }
//
//                var routeArray: [CLLocation] = []
//
//                let rawRoutes = try await HealthKitUtils.getWorkoutRoute(workout: workout)
//                for route in rawRoutes {
//                    let graph = try await HealthKitUtils.getLocationData(for: route)
//                    routeArray.append(contentsOf: graph)
//                }
//        }

    }
}
