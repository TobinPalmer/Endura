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

struct HeartRateData: Codable {
    var timestamp: Date
    var heartRate: HeartRateDataPoints
}

struct HeartRateDataPoints: Codable {
    var min: Double
    var max: Double
}

public struct RouteData: Codable {
    var timestamp: Date
    var location: LocationData
    var altitude: Double
    var heartRate: Double
    var pace: Double
}

public struct ActivityData: Codable {
    var uid: String
    var time: Date
    var distance: Double
    var duration: TimeInterval
    var comments: [ActivityComment]
    var likes: [String]
    var routeData: [RouteData]
}