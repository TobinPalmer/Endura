import Foundation

public struct SettingsModel: Codable {
    var notifications: Bool

    public init(notifications: Bool) {
        self.notifications = notifications
    }

    public init() {
        self.init(notifications: true)
    }
}
