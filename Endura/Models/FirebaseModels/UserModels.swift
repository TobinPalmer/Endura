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

public struct UserData: Cacheable {
    public let uid: String
    public var name: String {
        firstName + " " + lastName
    }

    public let firstName: String
    public let lastName: String
    public var profileImage: UIImage?
    public let friends: [String]

    public func fetchProfileImage() async -> UIImage? {
        if profileImage != nil {
            return profileImage
        }
        do {
            // Try loading firebase profile picture
            let image = try UIImage(data: await URLSession.shared.data(from: URL(string: "https://firebasestorage.googleapis.com/v0/b/runningapp-6ee99.appspot.com/o/users%2F\(uid)%2FprofilePicture?alt=media")!).0)
            if image == nil { // If firebase profile picture fails, load ui-avatars profile picture
                return try UIImage(data: await URLSession.shared.data(from: URL(string: "https://ui-avatars.com/api/?name=\(firstName)+\(lastName)&background=0D8ABC&color=fff")!).0)
            }
            return image
        } catch {
            Global.log.error("Error fetching profile image: \(error)")
        }
        return nil
    }

    public func updateCache(_ cache: UserDataCache) {
        cache.uid = uid
        cache.firstName = firstName
        cache.lastName = lastName
        cache.friends = friends
        if let profileImage = profileImage {
            cache.profileImage = profileImage.jpegData(compressionQuality: 1.0)
        } else if let cachedUserData = CacheUtils.fetchListedObject(UserDataCache.self, predicate: CacheUtils.predicateMatchingField("uid", value: uid)).first {
            cache.profileImage = cachedUserData.profileImage
        } else {
            cache.profileImage = nil
        }
    }

    public static func fromCache(_ cache: UserDataCache) -> UserData {
        UserData(
            uid: cache.uid!,
            firstName: cache.firstName!,
            lastName: cache.lastName!,
            profileImage: cache.profileImage != nil ? UIImage(data: cache.profileImage!) : nil,
            friends: cache.friends!
        )
    }
}

public struct UserDocument: Codable {
    public let firstName: String
    public let lastName: String
    public let friends: [String]
    public let role: Roles?
    public let birthday: Date
    public let gender: UserGender
    public let email: String
    public var lastNotificationsRead: Date?
}

public struct ActiveUserData: Cacheable {
    public let uid: String
    public var name: String {
        firstName + " " + lastName
    }

    public let firstName: String
    public let lastName: String
    public let friends: [String]
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
