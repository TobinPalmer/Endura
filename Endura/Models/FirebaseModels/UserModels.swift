import Foundation
import SwiftUI

public enum Roles: String, Codable {
    case ADMIN = "admin"
    case USER = "user"
}

public struct UserData {
    var uid: String
    var name: String
    var firstName: String
    var lastName: String
    var profileImage: UIImage?
    var friends: [String]
    var role: Roles?
}

public struct UserDocument: Codable {
    var firstName: String
    var lastName: String
    var friends: [String]
    var role: Roles?
}
