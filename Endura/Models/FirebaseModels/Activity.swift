//
// Created by Tobin Palmer on 7/17/23.
//

typealias HashCode = Codable & Hashable

import Foundation
import FirebaseFirestore

public struct ActivityComment: HashCode {
    let userId: String
    let time: Date
    let message: String
}

public struct Location: HashCode {
    let latitude: Double
    let longitude: Double
}

public struct Activity: Hashable {
    let userId: String
    let time: Date
    let duration: Double
    let distance: Double
    let location: [Location]
    let likes: [String]
    let comments: [ActivityComment]
}

struct ActivityDocument: Codable {
    var userId: String
    var time: Date
    var duration: Double
    var distance: Double
    var location: [Location]
}
