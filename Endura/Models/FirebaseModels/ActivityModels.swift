import FirebaseFirestore
import Foundation
import MapKit

public enum GraphType: String, Codable {
    case cadence
    case elevation
    case groundContactTime
    case heartRate
    case pace
    case power
    case strideLength
    case verticleOscillation
}

public typealias LineGraphData = [(Date, Double)]

public struct ActivityCommentData: Codable, Hashable {
    let message: String
    let time: Date
    let uid: String
}

public struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
}

public struct HeartRateData: Codable {
    var timestamp: Date
    var heartRate: Double
}

public struct CadenceData: Codable {
    var timestamp: Date
    var cadence: Double
}

public struct PowerData: Codable {
    var timestamp: Date
    var power: Double
}

public struct GroundContactTimeData: Codable {
    var timestamp: Date
    var groundContactTime: Double
}

public struct StrideLengthData: Codable {
    var timestamp: Date
    var strideLength: Double
}

public struct VerticleOscillationData: Codable {
    var timestamp: Date
    var verticleOscillation: Double
}

public struct RouteData: Codable {
    var altitude: Double
    var cadence: Double
    var heartRate: Double
    var groundContactTime: Double
    var location: LocationData
    var pace: Double
    var power: Double
    var strideLength: Double
    var timestamp: Date
    var verticleOscillation: Double
}

/// The same as RouteData, but with a fraction of the values to be more optimised for graphing and quick preview
public struct GraphData: Codable {
    var altitude: Double
    var cadence: Double
    var heartRate: Double
    var groundContactTime: Double
    var pace: Double
    var power: Double
    var strideLength: Double
    var timestamp: Date
    var verticleOscillation: Double
}

public struct ActivityRouteData: Codable {
    var graphData: [GraphData]
    var graphInterval: Int
    var routeData: [RouteData]
}

public struct ActivityGridStatsData: Codable {
    var averagePower: Double?
    var calories: Double
    var distance: Double
    var duration: TimeInterval
    var pace: Double {
        distance / duration
    }

    var time: Date
    var totalDuration: TimeInterval
    var uid: String
}

public struct ActivityHeaderData: Codable {
    var startTime: Date
    var startLocation: LocationData?
    var startCity: String?
    var uid: String
}

protocol ActivityDataProtocol {
    var averagePower: Double? { get }
    var calories: Double { get }
    var distance: Double { get }
    var duration: TimeInterval { get }
    var time: Date { get }
    var totalDuration: TimeInterval { get }
    var uid: String { get }
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

public struct ActivityData: Codable, ActivityDataProtocol {
    var averagePower: Double?
    var calories: Double
    var comments: [ActivityCommentData]
    var distance: Double
    var description: String
    var duration: TimeInterval
    var likes: [String]
    var pace: Double {
        distance / duration
    }

    var startCity: String
    var startLocation: LocationData
    var time: Date
    var title: String
    var totalDuration: TimeInterval
    var uid: String

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
            likes: likes,
            startCity: startCity,
            startLocation: startLocation,
            time: time,
            title: title,
            totalDuration: totalDuration,
            uid: uid
        )
    }
}

public struct ActivityDataWithRoute: Codable, ActivityDataProtocol {
    var averagePower: Double?
    var calories: Double
    var comments: [ActivityCommentData]
    var data: ActivityRouteData
    var distance: Double
    var description: String
    var duration: TimeInterval
    var likes: [String]
    var pace: Double {
        distance / duration
    }

    var startCity: String
    var startLocation: LocationData
    var time: Date
    var title: String
    var totalDuration: TimeInterval
    var uid: String

    public func getDataWithoutRoute() -> ActivityData {
        ActivityData(
            averagePower: averagePower,
            calories: calories,
            comments: comments,
            distance: distance,
            description: description,
            duration: duration,
            likes: likes,
            startCity: startCity,
            startLocation: startLocation,
            time: time,
            title: title,
            totalDuration: totalDuration,
            uid: uid
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
        case .verticleOscillation:
            selector = {
                $0.verticleOscillation
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

protocol TimestampPoint: Codable {
    var timestamp: Date { get }
}

extension CadenceData: TimestampPoint {}

extension HeartRateData: TimestampPoint {}

extension PowerData: TimestampPoint {}

extension StrideLengthData: TimestampPoint {}

extension GroundContactTimeData: TimestampPoint {}

extension VerticleOscillationData: TimestampPoint {}
