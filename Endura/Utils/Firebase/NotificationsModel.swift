import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public final class NotificationsModel: ObservableObject {
    @Published public final var notifications: [NotificationData] = []
    @Published public final var lastRead: Date? = nil
    @Published public final var unreadCount: Int = 0

    init(lastRead: Date?) {
        self.lastRead = lastRead

        loadNotifications()
    }

    private final func loadNotifications() {
        let query = lastRead != nil ? Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("notifications").order(by: "timestamp", descending: true).whereField("timestamp", isGreaterThan: lastRead!) :
            Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("notifications").order(by: "timestamp", descending: true)

        query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                Global.log.error("Error fetching documents: \(error!)")
                return
            }

            snapshot.documentChanges.forEach { diff in
                if diff.type == .added {
                    do {
                        let data = try diff.document.data(as: NotificationData.self)
                        self.notifications.append(data)
                        self.unreadCount += 1
                    } catch {
                        Global.log.error("Error decoding notification: \(error)")
                    }
                }
            }
        }
    }

    public static func sendNotification(to uid: String, data: NotificationData) {
        do {
            try Firestore.firestore().collection("users").document(uid).collection("notifications").addDocument(from: data)
        } catch {
            Global.log.error("Error sending notification: \(error)")
        }
    }
}
