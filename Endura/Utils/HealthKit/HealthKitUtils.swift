//
// Created by Tobin Palmer on 7/18/23.
//

import CoreLocation
import FirebaseAuth
import Foundation
import HealthKit
import UIKit

public enum HealthKitUtils {
    private static let healthStore = HKHealthStore()

    public static func requestAuthorization() {
        let baseTypesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        var typesToRead: Set<HKObjectType> = baseTypesToRead

        if #available(iOS 16.0, *) {
            typesToRead.insert(HKObjectType.quantityType(forIdentifier: .runningPower)!)
            typesToRead.insert(HKObjectType.quantityType(forIdentifier: .runningVerticalOscillation)!)
            typesToRead.insert(HKObjectType.quantityType(forIdentifier: .runningGroundContactTime)!)
            typesToRead.insert(HKObjectType.quantityType(forIdentifier: .runningStrideLength)!)
        }

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { _, error in
            if let error = error {
                print("Authorization request failed: \(error.localizedDescription)")
                return
            }

            let sampleType = HKObjectType.workoutType()

            healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { _, error in
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

        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { _, completionHandler, errorOrNil in
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

    public static func getLocationData(for route: HKWorkoutRoute) async throws -> [CLLocation] {
        let locations = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
            var allLocations: [CLLocation] = []
            let query = HKWorkoutRouteQuery(route: route) { _, locationsOrNil, done, errorOrNil in
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
                healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: { _, samples, _, _, error in
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
        let query = await createHeartRateQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HeartRateData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileHeartRateDataFromResults(results, workout: workout)
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HealthKitErrors.unknownError)
                }
            }
            healthStore.execute(query)
        }
        return results
    }

    public static func getCadenceGraph(for workout: HKWorkout) async throws -> [CadenceData] {
        let interval = DateComponents(second: 1)
        let query = await createCadenceQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CadenceData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileCadenceDataFromResults(results, workout: workout)
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HealthKitErrors.unknownError)
                }
            }
            healthStore.execute(query)
        }

        return results
    }

    @available(iOS 16.0, *)
    public static func getGroundContactTimeGraph(for workout: HKWorkout) async throws -> [GroundContactTimeData] {
        let interval = DateComponents(second: 1)
        let query = await createGroundContactTimeQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[GroundContactTimeData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileGroundContactTimeDataFromResults(results, workout: workout)
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HealthKitErrors.unknownError)
                }
            }
            healthStore.execute(query)
        }

        return results
    }

    @available(iOS 16.0, *)
    public static func getStrideLengthGraph(for workout: HKWorkout) async throws -> [StrideLengthData] {
        let interval = DateComponents(second: 1)
        let query = await createStrideLengthQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[StrideLengthData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileStrideLengthDataFromResults(results, workout: workout)
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HealthKitErrors.unknownError)
                }
            }
            healthStore.execute(query)
        }

        return results
    }

    @available(iOS 16.0, *)
    public static func getVerticleOscillationGraph(for workout: HKWorkout) async throws -> [VerticleOscillationData] {
        let interval = DateComponents(second: 1)
        let query = await createVerticleOscillationQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[VerticleOscillationData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileVerticleOscillationDataFromResults(results, workout: workout)
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HealthKitErrors.unknownError)
                }
            }
            healthStore.execute(query)
        }

        return results
    }

    @available(iOS 16.0, *)
    public static func getPowerGraph(for workout: HKWorkout) async throws -> [PowerData] {
        let interval = DateComponents(second: 1)
        let query = await createPowerQueryForWorkout(workout, interval: interval)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PowerData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compilePowerDataFromResults(results, workout: workout)
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HealthKitErrors.unknownError)
                }
            }
            healthStore.execute(query)
        }

        return results
    }

    private static func createHeartRateQueryForWorkout(_ workout: HKWorkout, interval: DateComponents) async -> HKStatisticsCollectionQuery {
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

    @available(iOS 16.0, *)
    private static func createGroundContactTimeQueryForWorkout(_ workout: HKWorkout, interval: DateComponents) async -> HKStatisticsCollectionQuery {
        let quantityType = HKObjectType.quantityType(forIdentifier: .runningGroundContactTime)!
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: [.discreteMax, .discreteMin],
            anchorDate: workout.startDate,
            intervalComponents: interval
        )
    }

    @available(iOS 16.0, *)
    private static func createVerticleOscillationQueryForWorkout(_ workout: HKWorkout, interval: DateComponents) async -> HKStatisticsCollectionQuery {
        let quantityType = HKObjectType.quantityType(forIdentifier: .runningVerticalOscillation)!
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: [.discreteMax, .discreteMin],
            anchorDate: workout.startDate,
            intervalComponents: interval
        )
    }

    private static func createCadenceQueryForWorkout(_ workout: HKWorkout, interval: DateComponents) async -> HKStatisticsCollectionQuery {
        let quantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: [.cumulativeSum, .separateBySource],
            anchorDate: workout.startDate,
            intervalComponents: interval
        )
    }

    @available(iOS 16.0, *)
    private static func createStrideLengthQueryForWorkout(_ workout: HKWorkout, interval: DateComponents) async -> HKStatisticsCollectionQuery {
        let quantityType = HKObjectType.quantityType(forIdentifier: .runningStrideLength)!

        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: [.discreteMax, .discreteMin],
            anchorDate: workout.startDate,
            intervalComponents: interval
        )
    }

    @available(iOS 16.0, *)
    private static func createPowerQueryForWorkout(_ workout: HKWorkout, interval: DateComponents) async -> HKStatisticsCollectionQuery {
        let quantityType = HKObjectType.quantityType(forIdentifier: .runningPower)!

        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: [.discreteMax, .discreteMin],
            anchorDate: workout.startDate,
            intervalComponents: interval
        )
    }

    private static func compileCadenceDataFromResults(_ results: HKStatisticsCollection, workout: HKWorkout) -> [CadenceData] {
        var cadenceData = [CadenceData]()

        results.enumerateStatistics(from: workout.startDate, to: workout.endDate) { statistics, _ in
            if let sumQuantity = statistics.sumQuantity() {
                let duration = statistics.endDate.timeIntervalSince(statistics.startDate)
                let averageCadence = sumQuantity.doubleValue(for: HKUnit.count()) / (duration / 60)

                let startDate = statistics.startDate
                let endDate = statistics.endDate

                var currentDate = startDate
                while currentDate < endDate {
                    cadenceData.append(CadenceData(timestamp: currentDate, cadence: averageCadence))
                    currentDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
                }
            }
        }

        return cadenceData
    }

    @available(iOS 16.0, *)
    private static func compilePowerDataFromResults(_ results: HKStatisticsCollection, workout: HKWorkout) -> [PowerData] {
        var power = [PowerData]()

        results.enumerateStatistics(
            from: workout.startDate,
            to: workout.endDate
        ) { statistics, _ in
            if let minValue = statistics.minimumQuantity()?.doubleValue(for: HKUnit.watt()),
               let maxValue = statistics.maximumQuantity()?.doubleValue(for: HKUnit.watt())
            {
                let average = (minValue + maxValue) / 2
                let date = Date(timeIntervalSince1970: (statistics.startDate.timeIntervalSince1970 * 1_000_000).rounded() / 1_000_000)

                power.append(PowerData(timestamp: date, power: average))
            }
        }

        var filledArray = [PowerData]()

        for i in 0 ..< power.count {
            let currentTuple = power[i]

            if i > 0 {
                let previousTuple = power[i - 1]

                if let missingSeconds = Calendar.current.dateComponents([.second], from: previousTuple.timestamp, to: currentTuple.timestamp).second, missingSeconds > 1 {
                    let missingRange = sequence(first: previousTuple.timestamp.addingTimeInterval(1), next: { $0.addingTimeInterval(1) }).prefix(while: { $0 < currentTuple.timestamp })

                    for missingSecond in missingRange {
                        filledArray.append(PowerData(timestamp: missingSecond, power: previousTuple.power))
                    }
                }
            }

            filledArray.append(currentTuple)
        }

        return filledArray
    }

    @available(iOS 16.0, *)
    private static func compileStrideLengthDataFromResults(_ results: HKStatisticsCollection, workout: HKWorkout) -> [StrideLengthData] {
        var strideLength = [StrideLengthData]()

        results.enumerateStatistics(
            from: workout.startDate,
            to: workout.endDate
        ) { statistics, _ in
            if let minValue = statistics.minimumQuantity()?.doubleValue(for: HKUnit.meter()),
               let maxValue = statistics.maximumQuantity()?.doubleValue(for: HKUnit.meter())
            {
                let average = (minValue + maxValue) / 2
                let date = Date(timeIntervalSince1970: (statistics.startDate.timeIntervalSince1970 * 1_000_000).rounded() / 1_000_000)

                strideLength.append(StrideLengthData(timestamp: date, strideLength: average))
            }
        }

        var filledArray = [StrideLengthData]()

        for i in 0 ..< strideLength.count {
            let currentTuple = strideLength[i]

            if i > 0 {
                let previousTuple = strideLength[i - 1]

                if let missingSeconds = Calendar.current.dateComponents([.second], from: previousTuple.timestamp, to: currentTuple.timestamp).second, missingSeconds > 1 {
                    let missingRange = sequence(first: previousTuple.timestamp.addingTimeInterval(1), next: { $0.addingTimeInterval(1) }).prefix(while: { $0 < currentTuple.timestamp })

                    for missingSecond in missingRange {
                        filledArray.append(StrideLengthData(timestamp: missingSecond, strideLength: previousTuple.strideLength))
                    }
                }
            }

            filledArray.append(currentTuple)
        }

        return filledArray
    }

    @available(iOS 16.0, *)
    private static func compileVerticleOscillationDataFromResults(_ results: HKStatisticsCollection, workout: HKWorkout) -> [VerticleOscillationData] {
        var verticleOscillation = [VerticleOscillationData]()

        results.enumerateStatistics(
            from: workout.startDate,
            to: workout.endDate
        ) { statistics, _ in
            if let minValue = statistics.minimumQuantity()?.doubleValue(for: HKUnit.meter()),
               let maxValue = statistics.maximumQuantity()?.doubleValue(for: HKUnit.meter())
            {
                let average = (minValue + maxValue) / 2
                let date = Date(timeIntervalSince1970: (statistics.startDate.timeIntervalSince1970 * 1_000_000).rounded() / 1_000_000)

                verticleOscillation.append(VerticleOscillationData(timestamp: date, verticleOscillation: average))
            }
        }

        var filledArray = [VerticleOscillationData]()

        for i in 0 ..< verticleOscillation.count {
            let currentTuple = verticleOscillation[i]

            if i > 0 {
                let previousTuple = verticleOscillation[i - 1]

                if let missingSeconds = Calendar.current.dateComponents([.second], from: previousTuple.timestamp, to: currentTuple.timestamp).second, missingSeconds > 1 {
                    let missingRange = sequence(first: previousTuple.timestamp.addingTimeInterval(1), next: { $0.addingTimeInterval(1) }).prefix(while: { $0 < currentTuple.timestamp })

                    for missingSecond in missingRange {
                        filledArray.append(VerticleOscillationData(timestamp: missingSecond, verticleOscillation: previousTuple.verticleOscillation))
                    }
                }
            }

            filledArray.append(currentTuple)
        }

        return filledArray
    }

    @available(iOS 16.0, *)
    private static func compileGroundContactTimeDataFromResults(_ results: HKStatisticsCollection, workout: HKWorkout) -> [GroundContactTimeData] {
        var groundContactTime = [GroundContactTimeData]()

        results.enumerateStatistics(
            from: workout.startDate,
            to: workout.endDate
        ) { statistics, _ in
            if let minValue = statistics.minimumQuantity()?.doubleValue(for: HKUnit.second()),
               let maxValue = statistics.maximumQuantity()?.doubleValue(for: HKUnit.second())
            {
                let average = (minValue + maxValue) / 2
                let date = Date(timeIntervalSince1970: (statistics.startDate.timeIntervalSince1970 * 1_000_000).rounded() / 1_000_000)

                groundContactTime.append(GroundContactTimeData(timestamp: date, groundContactTime: average))
            }
        }

        var filledArray = [GroundContactTimeData]()

        for i in 0 ..< groundContactTime.count {
            let currentTuple = groundContactTime[i]

            if i > 0 {
                let previousTuple = groundContactTime[i - 1]

                if let missingSeconds = Calendar.current.dateComponents([.second], from: previousTuple.timestamp, to: currentTuple.timestamp).second, missingSeconds > 1 {
                    let missingRange = sequence(first: previousTuple.timestamp.addingTimeInterval(1), next: { $0.addingTimeInterval(1) }).prefix(while: { $0 < currentTuple.timestamp })

                    for missingSecond in missingRange {
                        filledArray.append(GroundContactTimeData(timestamp: missingSecond, groundContactTime: previousTuple.groundContactTime))
                    }
                }
            }

            filledArray.append(currentTuple)
        }

        return filledArray
    }

    private static func compileHeartRateDataFromResults(_ results: HKStatisticsCollection, workout: HKWorkout) -> [HeartRateData] {
        var heartRateData = [HeartRateData]()

        results.enumerateStatistics(
            from: workout.startDate,
            to: workout.endDate
        ) { statistics, _ in
            if let minValue = statistics.minimumQuantity()?.doubleValue(for: HKUnit(from: "count/min")),
               let maxValue = statistics.maximumQuantity()?.doubleValue(for: HKUnit(from: "count/min"))
            {
                let average = (minValue + maxValue) / 2
                let date = Date(timeIntervalSince1970: (statistics.startDate.timeIntervalSince1970 * 1_000_000).rounded() / 1_000_000)

                heartRateData.append(HeartRateData(timestamp: date, heartRate: average))
            }
        }

        var filledArray = [HeartRateData]()

        for i in 0 ..< heartRateData.count {
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
            ) { _, samples, error in
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

        var cadence = try await HealthKitUtils.getCadenceGraph(for: workout)

        var groundContactTime: [GroundContactTimeData]? = nil
        var power: [PowerData]? = nil
        var strideLength: [StrideLengthData]? = nil
        var verticleOscillation: [VerticleOscillationData]? = nil
        if #available(iOS 16.0, *) {
            groundContactTime = try await HealthKitUtils.getGroundContactTimeGraph(for: workout)
            power = try await HealthKitUtils.getPowerGraph(for: workout)
            strideLength = try await HealthKitUtils.getStrideLengthGraph(for: workout)
            verticleOscillation = try await HealthKitUtils.getVerticleOscillationGraph(for: workout)
        }

        var dataRate = 1

        if !data.isEmpty {
            var graphSectionData = (0, data[0].timestamp, [GraphData]())
            let maxPoints = 200

            if data.count > maxPoints {
                dataRate = data.count / maxPoints
            }

            data.removeSubrange(0 ... 5)
            for i in 0 ..< data.count {
                var heartRateAtPoint: Double?
                var cadenceAtPoint: Double?
                var powerAtPoint: Double?
                var verticleOscillationAtPoint: Double?
                var groundContactTimeAtPoint: Double?
                var strideLengthAtPoint: Double?

                let point = data[i]

                func updateGraphData<T: TimestampPoint>(_ data: inout [T], timestamp: Date, updateValue: (T) -> Void) {
                    for j in 0 ..< data.count {
                        if Int(data[j].timestamp.timeIntervalSince1970) == Int(timestamp.timeIntervalSince1970) {
                            updateValue(data[j])
                            data.removeSubrange(0 ... j)
                            break
                        }
                    }
                }

                updateGraphData(&cadence, timestamp: point.timestamp) {
                    cadenceAtPoint = $0.cadence
                }
                updateGraphData(&heartRate, timestamp: point.timestamp) {
                    heartRateAtPoint = $0.heartRate
                }

                if #available(iOS 16.0, *) {
                    if var power = power {
                        updateGraphData(&power, timestamp: point.timestamp) {
                            powerAtPoint = $0.power
                        }
                    }

                    if var groundContactTime = groundContactTime {
                        updateGraphData(&groundContactTime, timestamp: point.timestamp) {
                            groundContactTimeAtPoint = $0.groundContactTime
                        }
                    }

                    if var strideLength = strideLength {
                        updateGraphData(&strideLength, timestamp: point.timestamp) {
                            strideLengthAtPoint = $0.strideLength
                        }
                    }

                    if var verticleOscillation = verticleOscillation {
                        updateGraphData(&verticleOscillation, timestamp: point.timestamp) {
                            verticleOscillationAtPoint = $0.verticleOscillation
                        }
                    }
                }

                let routePoint = RouteData(
                    altitude: point.altitude,
                    cadence: cadenceAtPoint ?? 0.0,
                    heartRate: heartRateAtPoint ?? 0.0,
                    groundContactTime: 0.0,
                    location: LocationData(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude),
                    pace: point.speed,
                    power: powerAtPoint ?? 0.0,
                    strideLength: 0.0,
                    timestamp: point.timestamp,
                    verticleOscillation: 0.0
                )

                routeData.append(routePoint)

                let graphPoint = GraphData(
                    altitude: point.altitude,
                    cadence: cadenceAtPoint ?? 0.0,
                    heartRate: heartRateAtPoint ?? 0.0,
                    groundContactTime: 0.0,
                    pace: point.speed,
                    power: powerAtPoint ?? 0.0,
                    strideLength: 0.0,
                    timestamp: point.timestamp,
                    verticleOscillation: 0.0
                )

                if i % dataRate == 0 {
                    if i > 0 {
                        let filteredHeartRateArray = graphSectionData.2.filter {
                            $0.heartRate != 0.0
                        }
                        let filteredPaceArray = graphSectionData.2.filter {
                            $0.pace != 0.0
                        }
                        let filteredCadenceArray = graphSectionData.2.filter {
                            $0.cadence != 0.0
                        }
                        let filteredPowerArray = graphSectionData.2.filter {
                            $0.power != 0.0
                        }

                        let graphSectionPoint = GraphData(
                            altitude: graphSectionData.2.reduce(0) {
                                $0 + $1.altitude
                            } / Double(graphSectionData.2.count),
                            cadence: filteredCadenceArray.reduce(0) {
                                $0 + $1.cadence
                            } / Double(filteredCadenceArray.count),
                            heartRate: filteredHeartRateArray.reduce(0) {
                                $0 + $1.heartRate
                            } / Double(filteredHeartRateArray.count),
                            groundContactTime: groundContactTimeAtPoint ?? 0.0,
                            pace: filteredPaceArray.reduce(0) {
                                $0 + $1.pace
                            } / Double(filteredPaceArray.count),
                            power: filteredPowerArray.reduce(0) {
                                $0 + $1.power
                            } / Double(filteredPowerArray.count),
                            strideLength: strideLengthAtPoint ?? 0.0,
                            timestamp: graphSectionData.1,
                            verticleOscillation: verticleOscillationAtPoint ?? 0.0
                        )

                        graphData.append(graphSectionPoint)
                    }

                    graphSectionData = (i, point.timestamp, [graphPoint])
                } else {
                    graphSectionData.2.append(graphPoint)
                }
            }
        }

        let workoutData = try await ActivityDataWithRoute(
            averagePower: power == nil
                ? nil
                : power!.reduce(0) {
                    $0 + $1.power
                } / Double(power!.count),
            calories: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0.0,
            comments: [],
            data: ActivityRouteData(
                graphData: graphData,
                graphInterval: dataRate,
                routeData: routeData
            ),
            distance: workoutDistance,
            duration: workoutDuration,
            likes: [],
            startCity: data.first?.fetchCityAndCountry().0 ?? "",
            startLocation: LocationData(latitude: data.first?.coordinate.latitude ?? 0.0, longitude: data.first?.coordinate.longitude ?? 0.0),
            time: workout.startDate,
            totalDuration: workout.startDate.distance(to: workout.endDate),
            uid: AuthUtils.getCurrentUID()
        )

        return workoutData
    }
}
