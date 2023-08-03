//
// Created by Tobin Palmer on 7/18/23.
//

import Foundation
import CoreLocation
import HealthKit
import FirebaseAuth
import UIKit

public struct HealthKitUtils {
    private static let healthStore = HKHealthStore()

    public static func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Authorization request failed: \(error.localizedDescription)")
                return
            }

            let sampleType = HKObjectType.workoutType()

            healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { (success, error) in
                if let error = error {
                    print("Error enabling background delivery: \(error.localizedDescription)")
                    return
                } else {
                    print("Enabled background delivery of \(sampleType.identifier)")
                }
            }
        }
    }

    public static func subscribeToNewWorkouts() {
        let sampleType = HKObjectType.workoutType()

        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, errorOrNil) in
            if let error = errorOrNil {
                print("Error in observer query: \(error)")
                return
            }
//            NotificationUtils.sendNotification(title: "New workout", body: "New workout, this is clean", date: Date().addingTimeInterval(5))
            print("Received new workout")
            completionHandler()
        }

        healthStore.execute(query)
    }

//    public static func subscribeToStepCountUpdates() {
//        print("Watching for step count updates")
//        let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
//
//        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, errorOrNil) in
//            if let error = errorOrNil {
//                print("Error in observer query: \(error)")
//                return
//            }
//            NotificationUtils.sendNotification(title: "Step Count Update", body: "New step count update", date: Date().addingTimeInterval(5))
//            print("Received step count update")
//            completionHandler()
//        }
//
//        healthStore.execute(query)
//    }

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

    public static func getHeartRateGraph(for workout: HKWorkout) async throws -> [HeartRateData] {
        let interval = DateComponents(second: 1)
        let query = await createQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HeartRateData], Error>) in
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

    private static func compileDataFromResults(_ results: HKStatisticsCollection, workout: HKWorkout) -> [HeartRateData] {
        var heartRateData = [HeartRateData]()

        results.enumerateStatistics(
                from: workout.startDate,
                to: workout.endDate
        ) { statistics, _ in
            if let minValue = statistics.minimumQuantity()?.doubleValue(for: HKUnit(from: "count/min")),
               let maxValue = statistics.maximumQuantity()?.doubleValue(for: HKUnit(from: "count/min")) {
                let average = (minValue + maxValue) / 2
                let date = Date(timeIntervalSince1970: (statistics.startDate.timeIntervalSince1970 * 1000000).rounded() / 1000000)

                heartRateData.append(HeartRateData(timestamp: date, heartRate: average))
            }
        }

        var filledArray = [HeartRateData]()

        for i in 0..<heartRateData.count {
            let currentTuple = heartRateData[i]

            if i > 0 {
                let previousTuple = heartRateData[i - 1]

                if let missingSeconds = Calendar.current.dateComponents([.second], from: previousTuple.timestamp, to: currentTuple.timestamp).second, missingSeconds > 1 {
                    let missingRange = sequence(first: previousTuple.timestamp.addingTimeInterval(1), next: { $0.addingTimeInterval(1) }).prefix(while: { $0 < currentTuple.timestamp })

                    for missingSecond in missingRange {
                        filledArray.append(HeartRateData(timestamp: missingSecond, heartRate: previousTuple.heartRate))
                    }
                }
            }

            filledArray.append(currentTuple)
        }

        return filledArray
    }

    public static func getListOfWorkouts(limitTo: Int = 1, offset: Int = 0) async throws -> [HKWorkout?] {
        let workoutType = HKObjectType.workoutType()

        let walkingPredicate = HKQuery.predicateForWorkouts(with: .walking)
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)

        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [walkingPredicate, runningPredicate])

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                    sampleType: workoutType,
                    predicate: predicate,
                    limit: limitTo + offset,
                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { (query, samples, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let workouts = samples as? [HKWorkout?] {
                    let slicedWorkouts = Array(workouts.dropFirst(offset)) // Drop the first 'offset' workouts
                    continuation.resume(returning: slicedWorkouts)
                } else {
                    continuation.resume(returning: [])
                }
            }
            healthStore.execute(query)
        }
    }


    public static func workoutToActivityData(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
        let workoutDistance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
        let workoutDuration = workout.duration
        var routeData = [RouteData]()
        var graphData = [GraphData]()

        let routes = try await HealthKitUtils.getWorkoutRoute(workout: workout)
        var data = [CLLocation]()
        for route in routes {
            let routeData = try await HealthKitUtils.getLocationData(for: route)
            data.append(contentsOf: routeData)
        }

        var heartRate = try await HealthKitUtils.getHeartRateGraph(for: workout)

        var dataRate = 1

        if (!data.isEmpty) {
            var graphSectionData = (0, data[0].timestamp, [GraphData]())
            let maxPoints = 200

            let workoutEvents = workout.workoutEvents ?? []
            let workoutPausesArray = workoutEvents.filter {
                    $0.type == .pause || $0.type == .resume
                }
                .map({
                    $0.dateInterval
                })
            if (data.count > maxPoints) {
                dataRate = data.count / maxPoints
            }
            data.removeSubrange(0...5)
            for i in 0..<data.count {
                var heartRateAtPoint: Double?;
                let point = data[i]

                for j in 0..<heartRate.count {
                    if Int(heartRate[j].timestamp.timeIntervalSince1970) == Int(point.timestamp.timeIntervalSince1970) { // Check if dates are about equal
                        heartRateAtPoint = heartRate[j].heartRate
                        heartRate.removeSubrange(0...j) // Remove all previous heart rate points since they are no longer needed
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

                let graphPoint = GraphData(
                        timestamp: point.timestamp,
                        altitude: point.altitude,
                        heartRate: heartRateAtPoint ?? 0.0,
                        pace: point.speed
                )

                if i % dataRate == 0 {
                    if (i > 0) {
                        let filteredHeartRateArray = graphSectionData.2.filter({ $0.heartRate != 0.0 })
                        let filteredPaceArray = graphSectionData.2.filter({ $0.pace != 0.0 })

                        let graphSectionPoint = GraphData(
                                timestamp: graphSectionData.1,
                                altitude: graphSectionData.2.reduce(0, { $0 + $1.altitude }) / Double(graphSectionData.2.count),
                                heartRate: filteredHeartRateArray.reduce(0, { $0 + $1.heartRate }) / Double(filteredHeartRateArray.count),
                                pace: filteredPaceArray.reduce(0, { $0 + $1.pace }) / Double(filteredPaceArray.count)
                        )

                        graphData.append(graphSectionPoint)
                    }

                    graphSectionData = (i, point.timestamp, [graphPoint])
                } else {
                    graphSectionData.2.append(graphPoint)
                }
            }
        }

        let workoutData = ActivityDataWithRoute(
                uid: AuthUtils.getCurrentUID(),
                time: workout.startDate,
                distance: workoutDistance,
                duration: workoutDuration,
                data: ActivityRouteData(
                        routeData: routeData,
                        graphData: graphData,
                        graphInterval: dataRate
                ),
                comments: [],
                likes: []
        )

        return workoutData
    }
}
