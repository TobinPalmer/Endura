import Foundation
import SwiftUI

public enum Roles: String, Codable {
    case ADMIN
    case USER
}

public struct UserData {
    var uid: String
    var name: String
    var firstName: String
    var lastName: String
    var profileImage: UIImage?
    var friends: [String]
}

public struct UserDocument: Codable {
    var birthDate: String
    var email: String
    var firstName: String
    var lastName: String
    var friends: [String]
    var role: Roles
}
