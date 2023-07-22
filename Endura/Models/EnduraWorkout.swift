//
// Created by Tobin Palmer on 7/20/23.
//

import Foundation
import MapKit

public typealias HeartRateGraph = [(Date, (Double, Double))]
public typealias PaceGraph = [CLLocation]
public typealias HeartRateGraphData = [(Date, Double)]
public typealias PaceGraphData = [(Int, Double)]

public struct heartRateGraph {

}

public struct commentsInfo {
    var message: String
    var userId: String
    var time: Date
}

public struct comments {
    var id: String
}

public struct EnduraWorkout {
    var comments: [comments]
    var distance: Int
    var duration: Int
    var likes: [String]
    var location: [String]
    var time: Date
    var userId: String
}
