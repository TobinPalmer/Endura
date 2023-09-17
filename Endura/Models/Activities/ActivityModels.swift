import Foundation

public struct ActivityData: Codable, ActivityDataProtocol {
    public let averagePower: Double?
    public let calories: Double
    public let comments: [ActivityCommentData]
    public let splits: [ActivitySplitsData]
    public let distance: Double
    public let description: String
    public let duration: TimeInterval
    public let startCountry: String
    public let likes: [String]
    public var pace: Double {
        distance / duration
    }

    public let type: TrainingRunType
    public let startCity: String
    public let startLocation: LocationData
    public let time: Date
    public let title: String
    public let totalDuration: TimeInterval
    public let uid: String
    public let visibility: ActivityVisibility

    public func withRouteData(id: String) async -> ActivityDataWithRoute {
        let routeData = await ActivityUtils.getActivityRouteData(id: id)
        return ActivityDataWithRoute(
            averagePower: averagePower,
            calories: calories,
            comments: comments,
            data: routeData,
            splits: splits,
            distance: distance,
            description: description,
            duration: duration,
            startCountry: startCountry,
            workoutStart: time,
            likes: likes,
            type: type,
            startCity: startCity,
            startLocation: startLocation,
            time: time,
            title: title,
            totalDuration: totalDuration,
            uid: uid,
            visibility: visibility
        )
    }
}

public struct ActivityDataWithRoute: Codable, ActivityDataProtocol {
    public let averagePower: Double?
    public let calories: Double
    public let comments: [ActivityCommentData]
    public let data: ActivityRouteData
    public let splits: [ActivitySplitsData]
    public let distance: Double
    public let description: String
    public let duration: TimeInterval
    public let startCountry: String
    public let workoutStart: Date
    public let likes: [String]
    var pace: Double {
        distance / duration
    }

    public let type: TrainingRunType
    public let startCity: String
    public let startLocation: LocationData
    public let time: Date
    public var title: String
    public let totalDuration: TimeInterval
    public let uid: String
    public let visibility: ActivityVisibility

    public func getDataWithoutRoute() -> ActivityData {
        ActivityData(
            averagePower: averagePower,
            calories: calories,
            comments: comments,
            splits: splits,
            distance: distance,
            description: description,
            duration: duration,
            startCountry: startCountry,
            likes: likes,
            type: type,
            startCity: startCity,
            startLocation: startLocation,
            time: time,
            title: title,
            totalDuration: totalDuration,
            uid: uid,
            visibility: visibility
        )
    }

    public func getIndexedGraphData() -> IndexedGraphData {
        var graphData = IndexedGraphData()

        data.graphData.forEach { val in
            graphData[val.timestamp.roundedToNearestSecond()] = val
        }

        return graphData
    }

    public func getIndexedRouteLocationData() -> IndexedRouteLocationData {
        var routeData = IndexedRouteLocationData()

        data.routeData.forEach { val in
            routeData[val.timestamp.roundedToNearestSecond()] = val.location
        }

        return routeData
    }

    public func getGraphData() -> ExtractedGraphData {
        var paceGraph = IndexedLineGraphData()
        var cadenceGraph = IndexedLineGraphData()
        var elevationGraph = IndexedLineGraphData()
        var heartRateGraph = IndexedLineGraphData()
        var powerGraph = IndexedLineGraphData()
        var strideLengthGraph = IndexedLineGraphData()
        var verticalOscillationGraph = IndexedLineGraphData()

        data.graphData.forEach { val in
            if val.pace > 0 && !val.pace.isNaN && !val.pace.isInfinite {
                paceGraph[val.timestamp.roundedToNearestSecond()] = val.pace
            }

            if val.cadence > 0 && !val.cadence.isNaN && !val.cadence.isInfinite {
                cadenceGraph[val.timestamp.roundedToNearestSecond()] = val.cadence
            }

            if val.altitude > 0 && !val.altitude.isNaN && !val.altitude.isInfinite {
                elevationGraph[val.timestamp.roundedToNearestSecond()] = val.altitude
            }

            if val.heartRate > 0 && !val.heartRate.isNaN && !val.heartRate.isInfinite {
                heartRateGraph[val.timestamp.roundedToNearestSecond()] = val.heartRate
            }

            if val.power > 0 && !val.power.isNaN && !val.power.isInfinite {
                powerGraph[val.timestamp.roundedToNearestSecond()] = val.power
            }

            if val.strideLength > 0 && !val.strideLength.isNaN && !val.strideLength.isInfinite {
                strideLengthGraph[val.timestamp.roundedToNearestSecond()] = val.strideLength
            }

            if val.verticalOscillation > 0 && !val.verticalOscillation.isNaN && !val.verticalOscillation.isInfinite {
                verticalOscillationGraph[val.timestamp.roundedToNearestSecond()] = val.verticalOscillation
            }
        }

        return ExtractedGraphData(
            pace: paceGraph,
            cadence: cadenceGraph,
            elevation: elevationGraph,
            heartRate: heartRateGraph,
            power: powerGraph,
            strideLength: strideLengthGraph,
            verticalOscillation: verticalOscillationGraph
        )
    }

    public func getGraph(for type: GraphType) -> LineGraphData {
        var graphData = LineGraphData()
        var selector: (GraphData) -> Double

        switch type {
        case .pace:
            selector = {
                $0.pace
            }
        case .heartRate:
            selector = {
                $0.heartRate
            }
        case .elevation:
            selector = {
                $0.altitude
            }
        case .cadence:
            selector = {
                $0.cadence
            }
        case .power:
            selector = {
                $0.power
            }
        case .groundContactTime:
            selector = {
                $0.groundContactTime
            }
        case .strideLength:
            selector = {
                $0.strideLength
            }
        case .verticalOscillation:
            selector = {
                $0.verticalOscillation
            }
        }

        data.graphData.forEach { val in
            if selector(val) > 0 && !selector(val).isNaN && !selector(val).isInfinite {
                graphData.append((val.timestamp, selector(val)))
            }
        }

        return graphData
    }
}

protocol ActivityDataProtocol {
    var averagePower: Double? { get }
    var calories: Double { get }
    var distance: Double { get }
    var duration: TimeInterval { get }
    var time: Date { get }
    var totalDuration: TimeInterval { get }
    var uid: String { get }
    var startCountry: String { get }
    var startCity: String { get }
    var startLocation: LocationData { get }
    var description: String { get }
    var title: String { get }

    func withHeaderStats() -> ActivityHeaderData
    func withGridStats() -> ActivityGridStatsData
}

extension ActivityDataProtocol {
    public func withHeaderStats() -> ActivityHeaderData {
        ActivityHeaderData(
            startTime: time,
            startLocation: startLocation,
            startCountry: startCountry,
            startCity: startCity,
            uid: uid
        )
    }

    public func withGridStats() -> ActivityGridStatsData {
        ActivityGridStatsData(
            averagePower: averagePower,
            calories: calories,
            distance: distance,
            duration: duration,
            time: time,
            totalDuration: totalDuration,
            uid: uid
        )
    }
}

public struct ActivityDocument: Codable {
    var averagePower: Double?
    var calories: Double
    var comments: [ActivityCommentData]
    var splits: [ActivitySplitsData]
    var distance: Double
    var description: String
    var duration: TimeInterval
    var likes: [String]
    var type: TrainingRunType
    var startCountry: String
    var startCity: String
    var startLocation: LocationData
    var time: Date
    var title: String
    var totalDuration: TimeInterval
    var uid: String
    var uploadTime: Date
    var visibility: ActivityVisibility

    static func getDocument(for activity: ActivityDataWithRoute, uploadTime: Date) -> ActivityDocument {
        ActivityDocument(
            averagePower: activity.averagePower,
            calories: activity.calories,
            comments: activity.comments,
            splits: activity.splits,
            distance: activity.distance,
            description: activity.description,
            duration: activity.duration,
            likes: activity.likes,
            type: activity.type,
            startCountry: activity.startCountry,
            startCity: activity.startCity,
            startLocation: activity.startLocation,
            time: activity.time,
            title: activity.title,
            totalDuration: activity.totalDuration,
            uid: activity.uid,
            uploadTime: uploadTime,
            visibility: activity.visibility
        )
    }
}
