import Foundation

public struct ActivityCommentData: Codable, Hashable {
    let message: String
    let time: Date
    let uid: String
}

public struct ActivityData: Codable, ActivityDataProtocol {
    public let averagePower: Double?
    public let calories: Double
    public let comments: [ActivityCommentData]
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

public struct RouteData: Codable {
    public let altitude: Double
    public let distance: Double
    public let heartRate: Double
    public let location: LocationData
    public let pace: Double
    public let timestamp: Date
}

/// The same as RouteData, but with a fraction of the values to be more optimised for graphing and quick preview
public struct GraphData: Codable {
    public let altitude: Double
    public let cadence: Double
    public let distance: Double
    public let heartRate: Double
    public let groundContactTime: Double
    public let pace: Double
    public let power: Double
    public let strideLength: Double
    public let timestamp: Date
    public let verticalOscillation: Double
}

public struct ExtractedGraphData {
    public let pace: IndexedLineGraphData
    public let cadence: IndexedLineGraphData
    public let elevation: IndexedLineGraphData
    public let heartRate: IndexedLineGraphData
    public let power: IndexedLineGraphData
    public let strideLength: IndexedLineGraphData
    public let verticalOscillation: IndexedLineGraphData
}

public struct ActivityRouteData: Codable {
    public let graphData: [GraphData]
    public let graphInterval: Int
    public let routeData: [RouteData]
}

public struct ActivityGridStatsData: Codable {
    public var averagePower: Double?
    public let calories: Double
    public let distance: Double
    public let duration: TimeInterval
    var pace: Double {
        distance / duration
    }

    public let time: Date
    public let totalDuration: TimeInterval
    public let uid: String
}

public struct ActivityHeaderData: Codable {
    public let startTime: Date
    public var startLocation: LocationData?
    public var startCountry: String?
    public var startCity: String?
    public let uid: String
}

public struct LocationData: Codable {
    public let latitude: Double
    public let longitude: Double
}

public struct HeartRateData: Codable, TimestampPoint {
    public let timestamp: Date
    public let heartRate: Double
}

public struct CadenceData: Codable, TimestampPoint {
    public let timestamp: Date
    public let cadence: Double
}

public struct PowerData: Codable, TimestampPoint {
    public let timestamp: Date
    public let power: Double
}

public struct GroundContactTimeData: Codable, TimestampPoint {
    public let timestamp: Date
    public let groundContactTime: Double
}

public struct StrideLengthData: Codable, TimestampPoint {
    public let timestamp: Date
    public let strideLength: Double
}

public struct VerticalOscillationData: Codable, TimestampPoint {
    public let timestamp: Date
    public let verticalOscillation: Double
}

protocol TimestampPoint: Codable {
    var timestamp: Date { get }
}
