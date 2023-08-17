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
}

public typealias LineGraphData = [(Date, Double)]

public struct ActivityCommentData: Codable, Hashable {
    let uid: String
    let time: Date
    let message: String
}

public struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
}

public struct HeartRateData: Codable {
    var timestamp: Date
    var heartRate: Double
}

public struct RouteData: Codable {
    var timestamp: Date
    var location: LocationData
    var altitude: Double
    var heartRate: Double
    var pace: Double
}

// The same as RouteData, but with a fraction of the values to be more optimised for graphing and quick preview
public struct GraphData: Codable {
    var timestamp: Date
    var altitude: Double
    var heartRate: Double
    var pace: Double
}

public struct ActivityRouteData: Codable {
    var routeData: [RouteData]
    var graphData: [GraphData]
    var graphInterval: Int
}

public struct ActivityData: Codable {
    var uid: String
    var time: Date
    var distance: Double
    var duration: TimeInterval
    var pace: Double {
        distance / duration
    }

    var startLocation: LocationData
    var startCity: String
    var comments: [ActivityCommentData]
    var likes: [String]

    public func withRouteData(id: String) async -> ActivityDataWithRoute {
        let routeData = await ActivityUtils.getActivityRouteData(id: id)
        return ActivityDataWithRoute(uid: uid, time: time, distance: distance, duration: duration, startLocation: startLocation, startCity: startCity, data: routeData, comments: comments, likes: likes)
    }
}

public struct ActivityDataWithRoute {
    var uid: String
    var time: Date
    var distance: Double
    var duration: TimeInterval
    var pace: Double {
        distance / duration
    }

    var startLocation: LocationData
    var startCity: String
    var data: ActivityRouteData
    var comments: [ActivityCommentData]
    var likes: [String]

    public func getDataWithoutRoute() -> ActivityData {
        ActivityData(uid: uid, time: time, distance: distance, duration: duration, startLocation: startLocation, startCity: startCity, comments: comments, likes: likes)
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
        }

        data.graphData.forEach { val in
            if selector(val) > 0 && !selector(val).isNaN && !selector(val).isInfinite {
                graphData.append((val.timestamp, selector(val)))
            }
        }

        return graphData
    }

//    public func getPaceAndHeartRateGraphData() -> (LineGraphData, LineGraphData) {
//        var pace = LineGraphData()
//        var heartRate = LineGraphData()
//
//        data.graphData.forEach { val in
//            pace.append((val.timestamp, val.pace))
//            heartRate.append((val.timestamp, val.heartRate))
//        }
//
//        return (pace, heartRate)
//    }
}
