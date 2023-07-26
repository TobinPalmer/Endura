//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import FirebaseFirestore
import MapKit

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

public struct ActivityData: Codable {
    var uid: String
    var time: Date
    var distance: Double
    var duration: TimeInterval
    var routeData: [RouteData]
    var graphData: [GraphData]
    var graphInterval: Int
    var comments: [ActivityComment]
    var likes: [String]
}