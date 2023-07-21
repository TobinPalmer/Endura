//
// Created by Tobin Palmer on 7/20/23.
//

import Foundation

public typealias HeartRateGraph = [(Date, (Double, Double))]

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
