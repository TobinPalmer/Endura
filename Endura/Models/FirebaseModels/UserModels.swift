import Foundation
import SwiftUI

public enum Roles: String, Codable {
    case ADMIN = "admin"
    case USER = "user"
}

public enum UserGender: String, Codable {
    case MALE = "male"
    case FEMALE = "female"
    case OTHER = "other"
}

public struct UserData {
    public var uid: String
    public var name: String
    public var firstName: String
    public var lastName: String
    public var profileImage: UIImage?
    public var friends: [String]

    public var role: Roles?
    public var lastNotificationsRead: Date?
}

public struct UserTrainingData: Codable {
    public var schedule: [RunningSchedule]
}

public struct UserDocument: Codable {
    public var firstName: String
    public var lastName: String
    public var friends: [String]
    public var role: Roles?
    public var birthday: Date
    public var gender: UserGender
    public var email: String
    public var lastNotificationsRead: Date?
}
