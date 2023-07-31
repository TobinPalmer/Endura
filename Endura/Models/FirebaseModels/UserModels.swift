//
// Created by Brandon Kirbyson on 7/21/23.
//

import Foundation

struct UserData {
    var uid: String
    var name: String
    var firstName: String
    var lastName: String
    var profilePicture: String
    var friends: [String]
}

struct UserDocument: Codable {
    var firstName: String
    var lastName: String
    var friends: [String]
}

