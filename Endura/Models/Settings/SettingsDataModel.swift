import Foundation

public struct SettingsDataModel: Codable, Cacheable {
    public var notifications: Bool
    public var notificationsFriendRequest: Bool
    public var notificationsFriendRequestAccepted: Bool
    public var notificationsNewLike: Bool
    public var notificationsNewComment: Bool
    public var notificationsDailyTrainingPlan: Bool
    public var notificationsDailySummary: Bool
    public var notificationsFinishedActivity: Bool
    public var notificationsPostRunReminder: Bool
    public var defaultActivityVisibility: ActivityVisibility

    public func updateCache(_ cache: SettingsCache) {
        cache.notifications = notifications
        cache.notificationsFriendRequest = notificationsFriendRequest
        cache.notificationsFriendRequestAccepted = notificationsFriendRequestAccepted
        cache.notificationsNewLike = notificationsNewLike
        cache.notificationsNewComment = notificationsNewComment
        cache.notificationsDailyTrainingPlan = notificationsDailyTrainingPlan
        cache.notificationsDailySummary = notificationsDailySummary
        cache.notificationsFinishedActivity = notificationsFinishedActivity
        cache.notificationsPostRunReminder = notificationsPostRunReminder
        cache.defaultActivityVisibility = defaultActivityVisibility.rawValue
    }

    public static func fromCache(_ cache: SettingsCache) -> SettingsDataModel {
        SettingsDataModel(
            notifications: cache.notifications,
            notificationsFriendRequest: cache.notificationsFriendRequest,
            notificationsFriendRequestAccepted: cache.notificationsFriendRequestAccepted,
            notificationsNewLike: cache.notificationsNewLike,
            notificationsNewComment: cache.notificationsNewComment,
            notificationsDailyTrainingPlan: cache.notificationsDailyTrainingPlan,
            notificationsDailySummary: cache.notificationsDailySummary,
            notificationsFinishedActivity: cache.notificationsFinishedActivity,
            notificationsPostRunReminder: cache.notificationsPostRunReminder,
            defaultActivityVisibility: ActivityVisibility(rawValue: cache.defaultActivityVisibility ?? "none") ?? .none
        )
    }
}
