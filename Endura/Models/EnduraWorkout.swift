//
// Created by Tobin Palmer on 7/20/23.
//

import Foundation
import MapKit

public typealias HeartRateGraph = [(Date, (Double, Double))]
public typealias PaceGraph = [CLLocation]
public typealias HeartRateGraphData = [(Date, Double)]
public typealias PaceGraphData = [(Int, Double)]

public struct PaceGraphDataEncodable: Encodable {
    var index: Int
    var speed: Double

    init(tuple: (Int, Double)) {
        index = tuple.0
        speed = tuple.1
    }
}

public struct HeartRateGraphDataEncodable: Encodable {
    var index: Date
    var heartRate: Double

    init(tuple: (Date, Double)) {
        index = tuple.0
        heartRate = tuple.1
    }
}

public struct commentsInfo: Codable {
    var message: String
    var userId: String
    var time: Date
}

public struct comments: Codable {
    var id: String
}

extension CLLocation: Encodable {
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case horizontalAccuracy
        case verticalAccuracy
        case speed
        case course
        case timestamp
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(course, forKey: .course)
        try container.encode(timestamp, forKey: .timestamp)
    }
}


public struct EnduraWorkout: Encodable {
    var comments: [comments]
    var distance: Double
    var duration: TimeInterval
    var likes: [String]
    var location: [PaceGraphDataEncodable]
    var heartRate: [HeartRateGraphDataEncodable]
    var time: Date
    var route: [CLLocation]
    var userId: String
}
