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

// Endura workouts, not HealthKit workouts
public struct WorkoutUtils {
    public static func getActivity(limitTo: Int = 5) async throws -> [ActivityData] {
        var activities: [ActivityData] = []

        let querySnapshot = try await Firestore.firestore().collection("activities").order(by: "time", descending: true).limit(to: limitTo).getDocuments()

        for document in querySnapshot.documents {
            do {
                let activityDocument = try document.data(as: ActivityDocument.self)
                let activity = ActivityData(
                    uid: activityDocument.userId, time: activityDocument.time, duration: activityDocument.duration, distance: activityDocument.distance, location: activityDocument.location, likes: [], comments: [])
                activities.append(activity)
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }

        return activities
    }

    public static func workoutToEnduraWorkout(_ workout: HKWorkout) async throws -> EnduraWorkout {
        do {
            let workoutDistance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
            let workoutDuration = workout.duration
            var rawPaceData: PaceGraph = []
            let routes = try await HealthKitUtils.getWorkoutRoute(workout: workout)
            for route in routes {
                let graph = try await HealthKitUtils.getLocationData(for: route)
                rawPaceData.append(contentsOf: graph)
            }
            let paceData = rawPaceData.map {
                $0.speed
            }

            var paceGraph: PaceGraphData {
                Array(zip(Array(0..<paceData.count), paceData))
            }

            let smoothPaceGraph: PaceGraphData = paceGraph.map { (index, value) in
                (index, value.rounded(toPlaces: 2))
            }

            async let heartRate = try HealthKitUtils.getHeartRateGraph(for: workout)
            let flattenedArry = try await heartRate.flatMap {
                $0
            }

            let dates = flattenedArry.map {
                $0.0
            }

            let values = flattenedArry.map {
                $0.1
            }

            let heartRateGraph: HeartRateGraphData = Array(zip(dates, values.map {
                $0.0
            }))

            let startTime = workout.startDate

            let finalPaceGraph: [PaceGraphDataEncodable] = smoothPaceGraph.map {
                PaceGraphDataEncodable(tuple: $0)
            }

            let finalHeartRateGraph: [HeartRateGraphDataEncodable] = heartRateGraph.map {
                HeartRateGraphDataEncodable(tuple: $0)
            }

            var routeArray: [CLLocation] = []

            let rawRoutes = try await HealthKitUtils.getWorkoutRoute(workout: workout)
            for route in rawRoutes {
                let graph = try await HealthKitUtils.getLocationData(for: route)
                routeArray.append(contentsOf: graph)
            }

            let workoutData = EnduraWorkout(comments: [], distance: workoutDistance, duration: workoutDuration, likes: [], location: finalPaceGraph, heartRate: finalHeartRateGraph, time: startTime, route: routeArray, userId: "123")
            return workoutData
        } catch (let error) {
            print("Error occured", error)
            throw error
        }
    }
}
