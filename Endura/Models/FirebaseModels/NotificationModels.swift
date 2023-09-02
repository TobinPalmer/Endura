import Foundation

public enum NotificationType: String, Codable {
    case friendRequest = "friend_request"
    case friendRequestAccepted = "friend_request_accepted"
}

public struct NotificationData: Codable {
    public let type: NotificationType
    public let uid: String
    public let timestamp: Date
}
