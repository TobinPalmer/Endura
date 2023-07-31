//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import FirebaseFirestore
import MapKit

public typealias LineGraphData = [(Date, Double)]

public struct ActivityComment: Codable {
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
    var comments: [ActivityComment]
    var likes: [String]

    public func withRouteData(id: String) async -> ActivityDataWithRoute {
        let routeData = await ActivityUtils.getActivityRouteData(id: id)
        return ActivityDataWithRoute(uid: uid, time: time, distance: distance, duration: duration, data: routeData, comments: comments, likes: likes)
    }
}

public struct ActivityDataWithRoute {
    var uid: String
    var time: Date
    var distance: Double
    var duration: TimeInterval
    var data: ActivityRouteData
    var comments: [ActivityComment]
    var likes: [String]

    public func getDataWithoutRoute() -> ActivityData {
        return ActivityData(uid: uid, time: time, distance: distance, duration: duration, comments: comments, likes: likes)
    }

    public func getPaceAndHeartRateGraphData() -> (LineGraphData, LineGraphData) {
        var pace = LineGraphData()
        var heartRate = LineGraphData()

        let _ = data.graphData.forEach { val in
            pace.append((val.timestamp, val.pace))
            heartRate.append((val.timestamp, val.heartRate))
        }

        return (pace, heartRate)
    }
}