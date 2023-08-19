//
// Created by Tobin Palmer on 7/17/23.
//

import FirebaseFirestore
import Foundation
import MapKit

public enum GraphType: String, Codable {
    case pace
    case heartRate
    case elevation
    case cadence
    case power
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

public struct RouteData: Codable {
    var altitude: Double
    var cadence: Double
    var heartRate: Double
    var location: LocationData
    var pace: Double
    var power: Double
    var timestamp: Date
}

// The same as RouteData, but with a fraction of the values to be more optimised for graphing and quick preview
public struct GraphData: Codable {
    var altitude: Double
    var cadence: Double
    var heartRate: Double
    var pace: Double
    var power: Double
    var timestamp: Date
}

public struct ActivityRouteData: Codable {
    var graphData: [GraphData]
    var graphInterval: Int
    var routeData: [RouteData]
}

public struct ActivityData: Codable {
    var averagePower: Double?
    var calories: Double
    var comments: [ActivityCommentData]
    var distance: Double
    var duration: TimeInterval
    var likes: [String]
    var pace: Double { distance / duration }
    var startCity: String
    var startLocation: LocationData
    var time: Date
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
            duration: duration,
            likes: likes,
            startCity: startCity,
            startLocation: startLocation,
            time: time,
            totalDuration: totalDuration,
            uid: uid
        )
    }
}

public struct ActivityDataWithRoute {
    var averagePower: Double?
    var calories: Double
    var comments: [ActivityCommentData]
    var data: ActivityRouteData
    var distance: Double
    var duration: TimeInterval
    var likes: [String]
    var pace: Double { distance / duration }
    var startCity: String
    var startLocation: LocationData
    var time: Date
    var totalDuration: TimeInterval
    var uid: String

    public func getDataWithoutRoute() -> ActivityData {
        ActivityData(
            averagePower: averagePower,
            calories: calories,
            comments: comments,
            distance: distance,
            duration: duration,
            likes: likes,
            startCity: startCity,
            startLocation: startLocation,
            time: time,
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

extension HeartRateData: TimestampPoint {}

extension CadenceData: TimestampPoint {}

extension PowerData: TimestampPoint {}
