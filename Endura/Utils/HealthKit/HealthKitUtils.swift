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

    public static func getLocationData(for route: HKWorkoutRoute) async -> [CLLocation] {
        let locations = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
            var allLocations: [CLLocation] = []
            let query = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
                if let error = errorOrNil {
                    continuation.resume(throwing: error)
                    return
                }
                guard let currentLocationBatch = locationsOrNil else {
                    fatalError("*** Invalid State: This can only fail if there was an error. ***")
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

    public static func getWorkoutRoute(workout: HKWorkout, completion: @escaping ([HKWorkoutRoute]?, Error?) -> Void) {
        let predicate = HKQuery.predicateForObjects(from: workout)
        let query = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, workoutRoutes, deletedObjects, anchor, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let workoutRoutes = workoutRoutes as? [HKWorkoutRoute] else {
                completion(nil, nil)
                return
            }

            completion(workoutRoutes, nil)
        }

        healthStore.execute(query)
    }

    public static func getHeartRateGraph(for workout: HKWorkout) async throws -> [[(Date, (Double, Double))]] {
        let interval = createIntervalForWorkout(workout)
        let query = try await createQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[[(Date, (Double, Double))]], Error>) in
            query.initialResultsHandler = { query, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileDataFromResults(results, workout: workout)
                    continuation.resume(returning: [data])
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: nil)) // replace with a meaningful error
                }
            }
            healthStore.execute(query)
        }
        return results
    }

    private static func createIntervalForWorkout(_ workout: HKWorkout) -> DateComponents {
        DateComponents(second: Int(workout.duration) / 200)
    }

    private static func createQueryForWorkout(_ workout: HKWorkout, interval: DateComponents) async throws -> HKStatisticsCollectionQuery {
        let quantityType = HKObjectType.quantityType(
            forIdentifier: .heartRate
        )!

        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
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
