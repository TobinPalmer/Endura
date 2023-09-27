import Foundation

public struct SettingsDataModel: Codable, Cacheable {
    public var notifications: NotificationsSettingsDataModel
    public var training: TrainingSettingsDataModel
    public var defaultActivityVisibility: ActivityVisibility

    public func updateCache(_ cache: SettingsCache) {
        cache.notifications = notifications.enabled
        cache.notificationsFriendRequest = notifications.friendRequest
        cache.notificationsFriendRequestAccepted = notifications.friendRequestAccepted
        cache.notificationsNewLike = notifications.newLike
        cache.notificationsNewComment = notifications.newComment
        cache.notificationsDailyTrainingPlan = notifications.dailyTrainingPlan
        cache.notificationsDailySummary = notifications.dailySummary
        cache.notificationsFinishedActivity = notifications.finishedActivity
        cache.notificationsPostRunReminder = notifications.postRunReminder

        cache.defaultActivityVisibility = defaultActivityVisibility.rawValue
    }

    public static func fromCache(_ cache: SettingsCache) -> SettingsDataModel {
        SettingsDataModel(
            notifications: NotificationsSettingsDataModel(
                enabled: cache.notifications,
                friendRequest: cache.notificationsFriendRequest,
                friendRequestAccepted: cache.notificationsFriendRequestAccepted,
                newLike: cache.notificationsNewLike,
                newComment: cache.notificationsNewComment,
                dailyTrainingPlan: cache.notificationsDailyTrainingPlan,
                dailySummary: cache.notificationsDailySummary,
                finishedActivity: cache.notificationsFinishedActivity,
                postRunReminder: cache.notificationsPostRunReminder
            ),
            training: TrainingSettingsDataModel(),
            defaultActivityVisibility: ActivityVisibility(rawValue: cache.defaultActivityVisibility ?? "none") ?? .none
        )
    }
}

public struct NotificationsSettingsDataModel: Codable {
    public var enabled: Bool
    public var friendRequest: Bool
    public var friendRequestAccepted: Bool
    public var newLike: Bool
    public var newComment: Bool
    public var dailyTrainingPlan: Bool
    public var dailySummary: Bool
    public var finishedActivity: Bool
    public var postRunReminder: Bool
}

public struct TrainingSettingsDataModel: Codable {}
