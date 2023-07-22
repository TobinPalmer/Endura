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

public struct EnduraWorkout: Encodable {
    var comments: [comments]
    var distance: Double
    var duration: TimeInterval
    var likes: [String]
    var location: [PaceGraphDataEncodable]
    var heartRate: [HeartRateGraphDataEncodable]
    var time: Date
    var userId: String
}
