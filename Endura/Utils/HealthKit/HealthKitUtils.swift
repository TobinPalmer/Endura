//
// Created by Tobin Palmer on 7/18/23.
//

import Foundation
import CoreLocation
import HealthKit

public struct HealthKitUtils {
    private static let healthStore = HKHealthStore()

    public static func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(), HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Authorization request failed: \(error.localizedDescription)")
                return
            }
        }
    }

    public static func getLocationData(for route: HKWorkoutRoute) async throws -> [CLLocation] {
        let locations = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
            var allLocations: [CLLocation] = []
            let query = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
                if let error = errorOrNil {
                    continuation.resume(throwing: error)
                    return
                }
                guard let currentLocationBatch = locationsOrNil else {
                    fatalError("Failed to get locations")
                }
                allLocations.append(contentsOf: currentLocationBatch)
                if done {
                    continuation.resume(returning: allLocations)
                }
            }
            healthStore.execute(query)
        }
        return locations
    }

    public static func getWorkoutRoute(workout: HKWorkout) async throws -> [HKWorkoutRoute] {
        let predicate = HKQuery.predicateForObjects(from: workout)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, workoutRoutes, deletedObjects, anchor, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workoutRoutes = workoutRoutes as? [HKWorkoutRoute] else {
                    continuation.resume(returning: [])
                    return
                }

                continuation.resume(returning: workoutRoutes)
            }
            healthStore.execute(query)
        }
    }

    public static func getHeartRateGraph(for workout: HKWorkout) async throws -> [HeartRateGraph] {
        let interval = DateComponents(second: Int(workout.duration) / 10)
        let query = try await createQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[[(Date, (Double, Double))]], Error>) in
            query.initialResultsHandler = { query, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileDataFromResults(results, workout: workout)
                    continuation.resume(returning: [data])
                } else {
                    continuation.resume(throwing: NSError(domain: "Something went wrong", code: -1, userInfo: nil))
                }
            }
            healthStore.execute(query)
        }
        return results
    }

    private static func createQueryForWorkout(_ workout: HKWorkout, interval: DateComponents) async throws -> HKStatisticsCollectionQuery {
        let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!

        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: [.discreteMax, .discreteMin],
            anchorDate: workout.startDate,
            intervalComponents: interval
        )
    }


    private static func compileDataFromResults(_ results: HKStatisticsCollection, workout: HKWorkout) -> [(Date, (Double, Double))] {
        var weeklyData: [Date: (Double, Double)] = [:]

        results.enumerateStatistics(
            from: workout.startDate,
            to: workout.endDate
        ) { statistics, _ in
            if let minValue = statistics.minimumQuantity()?.doubleValue(for: HKUnit(from: "count/min")),
               let maxValue = statistics.maximumQuantity()?.doubleValue(for: HKUnit(from: "count/min")) {
                weeklyData[statistics.startDate] = (minValue, maxValue)
            }
        }

        let data = [weeklyData]

        let flattened = data.compactMap {
            $0
        }

        let converted = flattened.map {
            $0.map {
                ($0.key, $0.value)
            }
        }

        let combined = converted.flatMap {
            $0
        }

        let sorted = combined.sorted {
            $0.0 < $1.0
        }

        return sorted
    }

    public static func getListOfWorkouts(limitTo: Int = 1) async throws -> [HKWorkout?] {
        let workoutType = HKObjectType.workoutType()

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: nil,
                limit: limitTo,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { (query, samples, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let workouts = samples as? [HKWorkout?] {
                    continuation.resume(returning: workouts)
                } else {
                    continuation.resume(returning: [])
                }
            }
            healthStore.execute(query)
        }
    }
}
