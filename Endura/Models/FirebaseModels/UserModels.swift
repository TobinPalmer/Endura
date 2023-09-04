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
    public var name: String {
        firstName + " " + lastName
    }

    public var firstName: String
    public var lastName: String
    public var profileImage: UIImage?
    public var friends: [String]
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

public struct ActiveUserData: Cacheable {
    public var uid: String
    public var name: String {
        firstName + " " + lastName
    }

    public var firstName: String
    public var lastName: String
    public var profileImage: UIImage?
    public var friends: [String]
    public var role: Roles?
    public var lastNotificationsRead: Date?

    public func updateCache(_ cache: ActiveUserDataCache) {
        cache.uid = uid
        cache.firstName = firstName
        cache.lastName = lastName
        cache.friends = friends
        cache.role = role?.rawValue ?? Roles.USER.rawValue
        cache.lastNotificationsRead = lastNotificationsRead
    }

    public static func fromCache(_ cache: ActiveUserDataCache) -> ActiveUserData {
        ActiveUserData(
            uid: cache.uid!,
            firstName: cache.firstName!,
            lastName: cache.lastName!,
            friends: cache.friends!,
            role: Roles(rawValue: cache.role!),
            lastNotificationsRead: cache.lastNotificationsRead
        )
    }
}
