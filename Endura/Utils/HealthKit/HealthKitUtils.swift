//
// Created by Tobin Palmer on 7/18/23.
//

import CoreLocation
import FirebaseAuth
import Foundation
import HealthKit
import UIKit

private enum UnitType {
    case string(String)
    case unit(HKUnit)
}

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

        func updateGraphData<T: TimestampPoint>(_ data: inout [T], timestamp: Date, updateValue: (T) -> Void) {
            for j in 0 ..< data.count {
                if Int(data[j].timestamp.timeIntervalSince1970) == Int(timestamp.timeIntervalSince1970) {
                    updateValue(data[j])
                    data.removeSubrange(0 ... j)
                    break
                }
            }
        }

        if !data.isEmpty {
            var graphSectionData = (0, data[0].timestamp, [GraphData]())
            let maxPoints = 150

            if data.count > maxPoints {
                dataRate = Int(data.count / maxPoints)
            }

            print("Data rate, ", dataRate)

            data.removeSubrange(0 ... 5)

            var heartRateAtPoint: Double?
            var cadenceAtPoint: Double?
            var powerAtPoint: Double?
            var verticleOscillationAtPoint: Double?
            var groundContactTimeAtPoint: Double?
            var strideLengthAtPoint: Double?

            for i in 0 ..< data.count where i % dataRate == 0 {
                let point = data[i]

                updateGraphData(&cadence, timestamp: point.timestamp) {
                    cadenceAtPoint = $0.cadence
                }

                updateGraphData(&heartRate, timestamp: point.timestamp) {
                    heartRateAtPoint = $0.heartRate
                }

                if #available(iOS 16.0, *) {
                    if var power = power, var groundContactTime = groundContactTime, var strideLength = strideLength, var verticleOscillation = verticleOscillation {
                        updateGraphData(&power, timestamp: point.timestamp) {
                            powerAtPoint = $0.power
                        }

                        updateGraphData(&groundContactTime, timestamp: point.timestamp) {
                            groundContactTimeAtPoint = $0.groundContactTime
                        }

                        updateGraphData(&strideLength, timestamp: point.timestamp) {
                            strideLengthAtPoint = $0.strideLength
                        }

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

                if i > 0 {
                    var altitudeSum = 0.0
                    var cadenceSum = 0.0
                    var heartRateSum = 0.0
                    var paceSum = 0.0
                    var powerSum = 0.0

                    for data in graphSectionData.2 {
                        altitudeSum += data.altitude

                        if data.cadence != 0.0 {
                            cadenceSum += data.cadence
                        }
                        if data.heartRate != 0.0 {
                            heartRateSum += data.heartRate
                        }
                        if data.pace != 0.0 {
                            paceSum += data.pace
                        }
                        if data.power != 0.0 {
                            powerSum += data.power
                        }
                    }

                    let graphSectionPoint = GraphData(
                        altitude: altitudeSum / Double(graphSectionData.2.count),
                        cadence: cadenceSum / 1.0,
                        heartRate: heartRateSum / 1.0,
                        groundContactTime: groundContactTimeAtPoint ?? 0.0,
                        pace: paceSum / 1.0,
                        power: powerSum / 1.0,
                        strideLength: strideLengthAtPoint ?? 0.0,
                        timestamp: graphSectionData.1,
                        verticleOscillation: verticleOscillationAtPoint ?? 0.0
                    )

                    graphData.append(graphSectionPoint)

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

    public static func getHeartRateGraph(for workout: HKWorkout) async throws -> [HeartRateData] {
        let interval = DateComponents(second: 1)
        let query = await createWorkoutQuery(workout: workout, interval: interval, quantityType: HKObjectType.quantityType(forIdentifier: .heartRate)!)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HeartRateData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileResultsFromWorkoutDiscreteMinMax(results, workout: workout, unit: .string("count/min"), dataType: HeartRateData.self)
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
        let query = await createWorkoutQuery(workout: workout, interval: interval, quantityType: HKObjectType.quantityType(forIdentifier: .stepCount)!, options: [.cumulativeSum, .separateBySource])

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CadenceData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileResultsFromWorkoutCumulative(results, workout: workout, unit: .unit(.count()), dataType: CadenceData.self)
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
        let query = await createWorkoutQuery(workout: workout, interval: interval, quantityType: HKObjectType.quantityType(forIdentifier: .runningGroundContactTime)!)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[GroundContactTimeData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileResultsFromWorkoutDiscreteMinMax(results, workout: workout, unit: .unit(.secondUnit(with: .milli)), dataType: GroundContactTimeData.self)
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
        let query = await createWorkoutQuery(workout: workout, interval: interval, quantityType: HKObjectType.quantityType(forIdentifier: .runningStrideLength)!)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[StrideLengthData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileResultsFromWorkoutDiscreteMinMax(results, workout: workout, unit: .unit(.meter()), dataType: StrideLengthData.self)
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
        let query = await createWorkoutQuery(workout: workout, interval: interval, quantityType: HKObjectType.quantityType(forIdentifier: .runningVerticalOscillation)!)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[VerticleOscillationData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileResultsFromWorkoutDiscreteMinMax(results, workout: workout, unit: .unit(.meter()), dataType: VerticleOscillationData.self)
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
        let query = await createWorkoutQuery(workout: workout, interval: interval, quantityType: HKObjectType.quantityType(forIdentifier: .runningPower)!)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PowerData], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    let data = compileResultsFromWorkoutDiscreteMinMax(results, workout: workout, unit: .unit(.watt()), dataType: PowerData.self)
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HealthKitErrors.unknownError)
                }
            }
            healthStore.execute(query)
        }

        return results
    }

    private static func createWorkoutQuery(workout: HKWorkout, interval: DateComponents, quantityType: HKQuantityType, options: HKStatisticsOptions = [.discreteMax, .discreteMin]) async -> HKStatisticsCollectionQuery {
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options,
            anchorDate: workout.startDate,
            intervalComponents: interval
        )
    }

    private static func compileResultsFromWorkoutCumulative<T: TimestampPoint>(_ results: HKStatisticsCollection,
                                                                               workout: HKWorkout,
                                                                               unit _: UnitType,
                                                                               dataType: T.Type) -> [T] where T: Codable
    {
        var dataPoints = [T]()

        results.enumerateStatistics(from: workout.startDate, to: workout.endDate) { statistics, _ in
            if let sumQuantity = statistics.sumQuantity() {
                let duration = statistics.endDate.timeIntervalSince(statistics.startDate)
                let averageCadence = sumQuantity.doubleValue(for: HKUnit.count()) / (duration / 60)

                let startDate = statistics.startDate
                let endDate = statistics.endDate

                var currentDate = startDate
                while currentDate < endDate {
                    switch dataType {
                    case is CadenceData.Type:
                        dataPoints.append(CadenceData(timestamp: currentDate, cadence: averageCadence) as! T)
                        currentDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
                    default:
                        break
                    }
                }
            }
        }

        return dataPoints
    }

    private static func compileResultsFromWorkoutDiscreteMinMax<T: TimestampPoint>(_ results: HKStatisticsCollection,
                                                                                   workout: HKWorkout,
                                                                                   unit: UnitType,
                                                                                   dataType: T.Type) -> [T] where T: Codable
    {
        var dataPoints = [T]()

        results.enumerateStatistics(from: workout.startDate, to: workout.endDate) { statistics, _ in
            var minVal: Double?
            var maxVal: Double?
            switch unit {
            case let .string(unitString):
                minVal = statistics.minimumQuantity()?.doubleValue(for: HKUnit(from: unitString))
                maxVal = statistics.maximumQuantity()?.doubleValue(for: HKUnit(from: unitString))

            case let .unit(unit):
                minVal = statistics.minimumQuantity()?.doubleValue(for: unit)
                maxVal = statistics.maximumQuantity()?.doubleValue(for: unit)
            }

            if let minValue = minVal,
               let maxValue = maxVal
            {
                let average = (minValue + maxValue) / 2
                let date = Date(timeIntervalSince1970: (statistics.startDate.timeIntervalSince1970 * 1_000_000).rounded() / 1_000_000)

                switch dataType {
                case is PowerData.Type:
                    let dataPoint = PowerData(timestamp: date, power: average)
                    dataPoints.append(dataPoint as! T)
                case is StrideLengthData.Type:
                    let dataPoint = StrideLengthData(timestamp: date, strideLength: average)
                    dataPoints.append(dataPoint as! T)
                case is VerticleOscillationData.Type:
                    let dataPoint = VerticleOscillationData(timestamp: date, verticleOscillation: average)
                    dataPoints.append(dataPoint as! T)
                case is GroundContactTimeData.Type:
                    let dataPoint = GroundContactTimeData(timestamp: date, groundContactTime: average)
                    dataPoints.append(dataPoint as! T)
                case is HeartRateData.Type:
                    let dataPoint = HeartRateData(timestamp: date, heartRate: average)
                    dataPoints.append(dataPoint as! T)
                default:
                    break
                }
            }
        }

        var filledArray = [T]()

        for i in 0 ..< dataPoints.count {
            let currentPoint = dataPoints[i]

            if i > 0 {
                let previousPoint = dataPoints[i - 1]

                if let missingSeconds = Calendar.current.dateComponents([.second], from: previousPoint.timestamp, to: currentPoint.timestamp).second, missingSeconds > 1 {
                    let missingRange = sequence(first: previousPoint.timestamp.addingTimeInterval(1), next: { $0.addingTimeInterval(1) }).prefix(while: { $0 < currentPoint.timestamp })

                    for missingSecond in missingRange {
                        switch dataType {
                        case is PowerData.Type:
                            let dataPoint = PowerData(timestamp: missingSecond, power: (previousPoint as! PowerData).power)
                            filledArray.append(dataPoint as! T)
                        case is StrideLengthData.Type:
                            let dataPoint = StrideLengthData(timestamp: missingSecond, strideLength: (previousPoint as! StrideLengthData).strideLength)
                            filledArray.append(dataPoint as! T)
                        case is VerticleOscillationData.Type:
                            let dataPoint = VerticleOscillationData(timestamp: missingSecond, verticleOscillation: (previousPoint as! VerticleOscillationData).verticleOscillation)
                            filledArray.append(dataPoint as! T)
                        case is GroundContactTimeData.Type:
                            let dataPoint = GroundContactTimeData(timestamp: missingSecond, groundContactTime: (previousPoint as! GroundContactTimeData).groundContactTime)
                            filledArray.append(dataPoint as! T)
                        case is HeartRateData.Type:
                            let dataPoint = HeartRateData(timestamp: missingSecond, heartRate: (previousPoint as! HeartRateData).heartRate)
                            filledArray.append(dataPoint as! T)
                        default:
                            break
                        }
                    }
                }
            }

            filledArray.append(currentPoint)
        }

        return filledArray
    }
}
