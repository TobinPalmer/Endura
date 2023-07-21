//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import FirebaseFirestore

public struct ActivityComment: Codable {
    let uid: String
    let time: Date
    let message: String
}

public struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

public struct ActivityData {
    let uid: String
    let time: Date
    let duration: Double
    let distance: Double
    let location: [Location]
    let likes: [String]
    let comments: [ActivityComment]
}

public struct ActivityDocument: Codable {
    var userId: String
    var time: Date
    var duration: Double
    var distance: Double
    var location: [Location]
}
