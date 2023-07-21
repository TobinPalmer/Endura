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
            // Create the route query.
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

//    public static func calculatePace(for route: HKWorkoutRoute) async -> [Double] {
//        let locations = await getLocationData(for: route)
//        var paces = [Double]()
//        for i in 1..<locations.count {
//            let previousLocation = locations[i - 1]
//            let currentLocation = locations[i]
//            let timeDifference = currentLocation.timestamp.timeIntervalSince(previousLocation.timestamp)
//            let distance = currentLocation.distance(from: previousLocation)
//            let distanceMiles = distance * 0.000621371
//            let pace = (timeDifference / 60) / distanceMiles
//            paces.append(pace)
//        }
//
//        return paces
//    }


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


    public static func getHeartRateGraph(
        for workout: HKWorkout,
        completion: @escaping (Result<[[Date: (Double, Double)]?], Error>) -> Void
    ) {
        let interval = DateComponents(second: Int(workout.duration) / 2)

        let quantityType = HKObjectType.quantityType(
            forIdentifier: .heartRate
        )!

        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: [.discreteMax, .discreteMin],
            anchorDate: workout.startDate,
            intervalComponents: interval
        )

        print("query", query)

        query.initialResultsHandler = { _, results, error in
            var weeklyData: [Date: (Double, Double)] = [:]

            guard let results = results else {
                completion(.failure(error!))
                return
            }

            results.enumerateStatistics(
                from: workout.startDate,
                to: workout.endDate
            ) { statistics, _ in
                if let minValue = statistics.minimumQuantity() {
                    if let maxValue = statistics.maximumQuantity() {
                        let minHeartRate = minValue.doubleValue(
                            for: HKUnit(from: "count/min")
                        )
                        let maxHeartRate = maxValue.doubleValue(
                            for: HKUnit(from: "count/min")
                        )

                        weeklyData[statistics.startDate] = (
                            minHeartRate, maxHeartRate
                        )
                    }
                }
            }

            completion(.success([weeklyData]))
        }

        healthStore.execute(query)
    }

    public static func getListOfWorkouts(
        limitTo: Int = 1, completion: @escaping (Result<[HKWorkout?], Error>) -> Void
    ) {
        let workoutType = HKObjectType.workoutType()
        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: nil,
            limit: limitTo,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { (query, samples, error) in
            if let error = error {
                completion(.failure(error))
            } else if let workouts = samples as? [HKWorkout?] {
                completion(.success(workouts))
            } else {
                completion(.success([]))
            }
        }

        healthStore.execute(query)
    }

}
