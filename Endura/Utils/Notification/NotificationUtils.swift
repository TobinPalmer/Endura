import Foundation
import SwiftyBeaver
import UserNotifications

public enum NotificationUtils {
    public static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("TODO: Notifications Ready")
            } else if let error = error {
                Global.log.error(error.localizedDescription)
            }
        }
    }

    public static func isAuthorized() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isAuthorized = false
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            isAuthorized = settings.authorizationStatus == .authorized
            semaphore.signal()
        }
        semaphore.wait()

        return isAuthorized
    }

    public static func sendNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
