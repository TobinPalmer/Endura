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
                Global.log.error("Authorization request failed: \(error.localizedDescription)")
                return
            }

            let sampleType = HKObjectType.workoutType()

            healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { _, error in
                if let error = error {
                    Global.log.error("Error enabling background delivery: \(error.localizedDescription)")
                    return
                } else {
                    print("TODO: Enabled background delivery of \(sampleType.identifier)")
                }
            }
        }
    }

    public static func isAuthorized() -> Bool {
        var typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        if #available(iOS 16.0, *) {
            typesToRead.insert(HKObjectType.quantityType(forIdentifier: .runningPower)!)
            typesToRead.insert(HKObjectType.quantityType(forIdentifier: .runningVerticalOscillation)!)
            typesToRead.insert(HKObjectType.quantityType(forIdentifier: .runningGroundContactTime)!)
            typesToRead.insert(HKObjectType.quantityType(forIdentifier: .runningStrideLength)!)
        }

        for type in typesToRead {
            if healthStore.authorizationStatus(for: type) == .notDetermined {
                return false
            }
        }

        return true
    }

    public static func isAuthorizedForProperty<T: HKObjectType>(_ property: T) -> Bool {
        healthStore.authorizationStatus(for: property) == .sharingAuthorized
    }

    public static func subscribeToNewWorkouts() {
        let sampleType = HKObjectType.workoutType()

        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { _, completionHandler, errorOrNil in
            if let error = errorOrNil {
                Global.log.error("Error in observer query: \(error)")
                return
            }
//            NotificationUtils.sendNotification(title: "New workout", body: "New workout, this is clean", date: Date().addingTimeInterval(5))
            print("TODO: Received new workout")
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

    public static func getFirstWorkoutRoute(workout: HKWorkout) async throws -> HKWorkoutRoute? {
        let predicate = HKQuery.predicateForObjects(from: workout)

        do {
            let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
                healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: predicate, anchor: nil, limit: 1, resultsHandler: { _, samples, _, _, error in
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

            return workouts.first
        } catch {
            throw HealthKitErrors.unknownError
        }
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

    public static func getWorkoutGridStatsData(for workout: HKWorkout) -> ActivityGridStatsData {
        let workoutDistance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
        let workoutDuration = workout.duration

        return ActivityGridStatsData(
            calories: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0.0,
            distance: workoutDistance,
            duration: workoutDuration,
            time: workout.startDate,
            totalDuration: workout.startDate.distance(to: workout.endDate),
            uid: AuthUtils.getCurrentUID()
        )
    }

    public static func getWorkoutHeaderData(for workout: HKWorkout) async throws -> ActivityHeaderData {
        let firstRoute = try? await HealthKitUtils.getFirstWorkoutRoute(workout: workout)
        let firstLocation: [CLLocation]?

        if let firstRoute = firstRoute {
            firstLocation = try? await HealthKitUtils.getLocationData(for: firstRoute)
        } else {
            firstLocation = nil
        }

        return try await ActivityHeaderData(
            startTime: workout.startDate,
            startLocation: firstRoute == nil ? nil : LocationData(latitude: firstLocation?.first?.coordinate.latitude ?? 0.0, longitude: firstLocation?.first?.coordinate.longitude ?? 0.0),
            startCity: firstLocation?.first?.fetchCityAndCountry().0 ?? nil,
            uid: AuthUtils.getCurrentUID()
        )
    }

    public static func workoutToActivityDataWithRoute(for workout: HKWorkout) async throws -> ActivityDataWithRoute {
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

        let heartRate = try await HealthKitUtils.getGraph(for: workout, quantityTypeIdentifier: .heartRate, unit: .string("count/min"), dataType: HeartRateData.self)
        let cadence = try await HealthKitUtils.getGraph(for: workout, quantityTypeIdentifier: .stepCount, options: [.cumulativeSum, .separateBySource], unit: .unit(.count()), dataType: CadenceData.self)

        var groundContactTime: [GroundContactTimeData]? = nil
        var power: [PowerData]? = nil
        var strideLength: [StrideLengthData]? = nil
        var verticalOscillation: [VerticalOscillationData]? = nil
        if #available(iOS 16.0, *) {
            groundContactTime = try await HealthKitUtils.getGraph(for: workout, quantityTypeIdentifier: .runningGroundContactTime, unit: .unit(.secondUnit(with: .milli)), dataType: GroundContactTimeData.self)
            power = try await HealthKitUtils.getGraph(for: workout, quantityTypeIdentifier: .runningPower, unit: .unit(.watt()), dataType: PowerData.self)
            strideLength = try await HealthKitUtils.getGraph(for: workout, quantityTypeIdentifier: .runningStrideLength, unit: .unit(.meter()), dataType: StrideLengthData.self)
            verticalOscillation = try await HealthKitUtils.getGraph(for: workout, quantityTypeIdentifier: .runningVerticalOscillation, unit: .unit(.meter()), dataType: VerticalOscillationData.self)
        }

        // A dictionary of the combined workout metrics at each second
        var workoutMetrics: [Int: (
            heartRate: Double,
            cadence: Double,
            power: Double?,
            verticalOscillation: Double?,
            groundContactTime: Double?,
            strideLength: Double?
        )] = [:]

        // Combine the workout metrics into a dictionary
        for i in 0 ..< heartRate.count {
            let heartRatePoint = heartRate[i]
            let cadencePoint = cadence[safe: i] ?? CadenceData(timestamp: heartRatePoint.timestamp, cadence: 0.0)
            let powerPoint = power?[safe: i]
            let verticalOscillationPoint = verticalOscillation?[safe: i]
            let groundContactTimePoint = groundContactTime?[safe: i]
            let strideLengthPoint = strideLength?[safe: i]

            workoutMetrics[Int(heartRatePoint.timestamp.timeIntervalSince1970)] = (
                heartRate: heartRatePoint.heartRate,
                cadence: cadencePoint.cadence,
                power: powerPoint?.power,
                verticalOscillation: verticalOscillationPoint?.verticalOscillation,
                groundContactTime: groundContactTimePoint?.groundContactTime,
                strideLength: strideLengthPoint?.strideLength
            )
        }

        var dataRate = 1

        if !data.isEmpty {
            var graphSectionData = (0, data[0].timestamp, [GraphData]())
            let maxPoints = 150

            if data.count > maxPoints {
                dataRate = Int(data.count / maxPoints)
            }

            data.removeSubrange(0 ... 5)

            var heartRateAtPoint: Double?
            var cadenceAtPoint: Double?
            var powerAtPoint: Double?
            var verticalOscillationAtPoint: Double?
            var groundContactTimeAtPoint: Double?
            var strideLengthAtPoint: Double?

            var previousLocation: CLLocation?
            var totalDistance = 0.0
            let mileDistance = 1609.34
            var startTime: Date = data[safe: 0]?.timestamp ?? workout.startDate

            for i in 0 ..< data.count {
                let point = data[i]

//                if let previousLocation = previousLocation {
//                    let currentLocation = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
//                    let distance = previousLocation.distance(from: currentLocation)
//                    totalDistance += distance
//
//                    if totalDistance >= mileDistance {
//                        let endTime = point.timestamp
//                        let durationInSeconds = endTime.timeIntervalSince(startTime)
//                        let durationInMinutes = durationInSeconds / 60
                ////                        print("Mile split with total time \(durationInMinutes) minutes, with total distance \(totalDistance) meters")
//                        totalDistance -= mileDistance
//                        startTime = endTime
//                    }
//                }

                previousLocation = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)

                if let metricsAtPoint = workoutMetrics[Int(point.timestamp.timeIntervalSince1970)] {
                    cadenceAtPoint = metricsAtPoint.cadence
                    heartRateAtPoint = metricsAtPoint.heartRate
                    powerAtPoint = metricsAtPoint.power
                    verticalOscillationAtPoint = metricsAtPoint.verticalOscillation
                    groundContactTimeAtPoint = metricsAtPoint.groundContactTime
                    strideLengthAtPoint = metricsAtPoint.strideLength
                }

                let routePoint = RouteData(
                    altitude: point.altitude,
                    distance: 0.0,
                    heartRate: heartRateAtPoint ?? 0.0,
                    location: LocationData(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude),
                    pace: point.speed,
                    timestamp: point.timestamp
                )

                routeData.append(routePoint)

                let graphPoint = GraphData(
                    altitude: point.altitude,
                    cadence: cadenceAtPoint ?? 0.0,
                    distance: 0.0,
                    heartRate: heartRateAtPoint ?? 0.0,
                    groundContactTime: groundContactTimeAtPoint ?? 0.0,
                    pace: point.speed,
                    power: powerAtPoint ?? 0.0,
                    strideLength: strideLengthAtPoint ?? 0.0,
                    timestamp: point.timestamp,
                    verticalOscillation: verticalOscillationAtPoint ?? 0.0
                )

                // If not first and at a multiple of the data rate, average the data and add it to the graph data
                if i > 0 && i % dataRate == 0 {
                    // Averaging is (sum, count)
                    var altitudeAveraging = (0.0, 0.0)
                    var cadenceAveraging = (0.0, 0.0)
                    var heartRateAveraging = (0.0, 0.0)
                    var paceAveraging = (0.0, 0.0)
                    var powerAveraging = (0.0, 0.0)
                    var strideLengthAveraging = (0.0, 0.0)
                    var verticalOscillationAveraging = (0.0, 0.0)
                    var groundContactTimeAveraging = (0.0, 0.0)

                    // Average the data
                    for data in graphSectionData.2 {
                        if data.altitude != 0.0 {
                            altitudeAveraging.0 += data.altitude
                            altitudeAveraging.1 += 1
                        }
                        if data.cadence != 0.0 {
                            cadenceAveraging.0 += data.cadence
                            cadenceAveraging.1 += 1
                        }
                        if data.heartRate != 0.0 {
                            heartRateAveraging.0 += data.heartRate
                            heartRateAveraging.1 += 1
                        }
                        if data.pace != 0.0 {
                            paceAveraging.0 += data.pace
                            paceAveraging.1 += 1
                        }
                        if data.power != 0.0 {
                            powerAveraging.0 += data.power
                            powerAveraging.1 += 1
                        }
                        if data.strideLength != 0.0 {
                            strideLengthAveraging.0 += data.strideLength
                            strideLengthAveraging.1 += 1
                        }
                        if data.verticalOscillation != 0.0 {
                            verticalOscillationAveraging.0 += data.verticalOscillation
                            verticalOscillationAveraging.1 += 1
                        }
                        if data.groundContactTime != 0.0 {
                            groundContactTimeAveraging.0 += data.groundContactTime
                            groundContactTimeAveraging.1 += 1
                        }
                    }

                    func avg(_ data: (Double, Double)) -> Double {
                        data.0 / data.1
                    }

                    let graphSectionPoint = GraphData(
                        altitude: avg(altitudeAveraging),
                        cadence: avg(cadenceAveraging),
                        distance: 0.0,
                        heartRate: avg(heartRateAveraging),
                        groundContactTime: avg(groundContactTimeAveraging),
                        pace: avg(paceAveraging),
                        power: avg(powerAveraging),
                        strideLength: avg(strideLengthAveraging),
                        timestamp: graphSectionData.1.roundedToNearestSecond(),
                        verticalOscillation: avg(verticalOscillationAveraging)
                    )

                    graphData.append(graphSectionPoint)

                    graphSectionData = (i, point.timestamp, [graphPoint])
                } else {
                    graphSectionData.2.append(graphPoint)
                }
            }
        }

        let workoutData = try await ActivityDataWithRoute(
            averagePower: power?.isEmpty ?? true
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
            description: "",
            duration: workoutDuration,
            startCountry: data.first?.fetchCityAndCountry().1 ?? "",
            workoutStart: workout.startDate,
            likes: [],
            type: .none,
            startCity: data.first?.fetchCityAndCountry().0 ?? "",
            startLocation: LocationData(latitude: data.first?.coordinate.latitude ?? 0.0, longitude: data.first?.coordinate.longitude ?? 0.0),
            time: workout.startDate,
            title: "",
            totalDuration: workout.startDate.distance(to: workout.endDate),
            uid: AuthUtils.getCurrentUID(),
            visibility: .friends
        )

        return workoutData
    }

    private static func createWorkoutQuery(
        for workout: HKWorkout,
        with interval: DateComponents,
        quantityType: HKQuantityType,
        options: HKStatisticsOptions = [.discreteMax, .discreteMin]
    ) async -> HKStatisticsCollectionQuery {
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options,
            anchorDate: workout.startDate,
            intervalComponents: interval
        )
    }

    private static func compileResultsFromWorkoutCumulative<T: TimestampPoint>(
        _ results: HKStatisticsCollection,
        workout: HKWorkout,
        unit _: UnitType,
        dataType: T.Type
    ) -> [T] where T: Codable {
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

    private static func compileResultsFromWorkoutDiscreteMinMax<T: TimestampPoint>(
        _ results: HKStatisticsCollection,
        workout: HKWorkout,
        unit: UnitType,
        dataType: T.Type
    ) -> [T] where T: Codable {
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
                case is VerticalOscillationData.Type:
                    let dataPoint = VerticalOscillationData(timestamp: date, verticalOscillation: average)
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
                        case is VerticalOscillationData.Type:
                            let dataPoint = VerticalOscillationData(timestamp: missingSecond, verticalOscillation: (previousPoint as! VerticalOscillationData).verticalOscillation)
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

    private static func getGraph<T: TimestampPoint>(
        for workout: HKWorkout,
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        options: HKStatisticsOptions = [.discreteMax, .discreteMin],
        unit: UnitType,
        dataType: T.Type
    ) async throws -> [T] where T: Codable {
        let interval = DateComponents(second: 1)
        let query = await createWorkoutQuery(for: workout, with: interval, quantityType: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, options: options)

        let results = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[T], Error>) in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let results = results {
                    if options.contains(.cumulativeSum) {
                        let data = compileResultsFromWorkoutCumulative(results, workout: workout, unit: unit, dataType: dataType)
                        continuation.resume(returning: data)
                    } else {
                        let data = compileResultsFromWorkoutDiscreteMinMax(results, workout: workout, unit: unit, dataType: dataType)
                        continuation.resume(returning: data)
                    }
                } else {
                    continuation.resume(throwing: HealthKitErrors.unknownError)
                }
            }
            healthStore.execute(query)
        }

        return results
    }
}
