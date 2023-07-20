//
// Created by Tobin Palmer on 7/20/23.
//

import Foundation

struct commentsInfo {
    var message: String
    var userId: String
    var time: Date
}

struct comments {
    var id: String
}

struct EnduraWorkout {
    var comments: [comments]
    var distance: Int
    var duration: Int
    var likes: [String]
    var location: [String]
    var time: Date
    var userId: String
}
