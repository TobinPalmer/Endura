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
        print("calling location data")
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
        do {
            let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
                healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: { (query, samples, deletedObjects, anchor, error) in
                    if let hasError = error {
                        continuation.resume(throwing: hasError)
                        return
                    }

                    guard let samples = samples else {
                        return
                    }
                    continuation.resume(returning: samples)
                }))
            }
            guard let workouts = samples as? [HKWorkoutRoute] else {
                throw HealthKitErrors.workoutFailedCast
            }

            return workouts
        } catch {
            throw HealthKitErrors.unknownError
        }
    }

    public static func getHeartRateGraph(for workout: HKWorkout) async throws -> HeartRateGraph {
        let interval = DateComponents(second: 1)
//        guard interval.second! > 0 else {
//            print("To low interval")
////            return (Date(), [(Date(), (0, 0))])
//        }
        let query = await createQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HeartRateGraph, Error>) in
            query.initialResultsHandler = { query, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileDataFromResults(results, workout: workout)
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HealthKitErrors.unknownError)
                }
            }
            healthStore.execute(query)
        }
        return results
    }

    private static func createQueryForWorkout(_ workout: HKWorkout, interval: DateComponents) async -> HKStatisticsCollectionQuery {
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

    private static func compileDataFromResults(_ results: HKStatisticsCollection, workout: HKWorkout) -> HeartRateGraph {
        var heartRateData = HeartRateGraph()

        results.enumerateStatistics(
                from: workout.startDate,
                to: workout.endDate
        ) { statistics, _ in
            if let minValue = statistics.minimumQuantity()?.doubleValue(for: HKUnit(from: "count/min")),
               let maxValue = statistics.maximumQuantity()?.doubleValue(for: HKUnit(from: "count/min")) {
                let average = (minValue + maxValue) / 2
                let date = Date(timeIntervalSince1970: (statistics.startDate.timeIntervalSince1970 * 1000000).rounded() / 1000000)

                heartRateData.append((date, average))
            }
        }

        var filledArray = HeartRateGraph()

        for i in 0..<heartRateData.count {
            let currentTuple = heartRateData[i]

            if i > 0 {
                let previousTuple = heartRateData[i - 1]

                if let missingSeconds = Calendar.current.dateComponents([.second], from: previousTuple.0, to: currentTuple.0).second, missingSeconds > 1 {
                    let missingRange = sequence(first: previousTuple.0.addingTimeInterval(1), next: { $0.addingTimeInterval(1) }).prefix(while: { $0 < currentTuple.0 })

//                        let missingRange = stride(from: previousTuple.0.addingTimeInterval(1), to: currentTuple.0, by: 1)
//
                    for missingSecond in missingRange {
                        filledArray.append((missingSecond, previousTuple.1))
                    }
                }
            }

            filledArray.append(currentTuple)
        }

        return filledArray
    }

    public static func getListOfWorkouts(limitTo: Int = 1) async throws -> [HKWorkout?] {
        let workoutType = HKObjectType.workoutType()

        let walkingPredicate = HKQuery.predicateForWorkouts(with: .walking)
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)

        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [walkingPredicate, runningPredicate])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                    sampleType: workoutType,
                    predicate: predicate,
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
                routeData: routeData,
                comments: [],
                likes: []
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
