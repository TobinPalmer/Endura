import Foundation

public struct SettingsModel: Codable, Cacheable {
    var notifications: Bool

    public func updateCache(_ cache: SettingsCache) {
        cache.notifications = notifications
    }

    public static func fromCache(_ cache: SettingsCache) -> SettingsModel {
        SettingsModel(notifications: cache.notifications)
    }
}
