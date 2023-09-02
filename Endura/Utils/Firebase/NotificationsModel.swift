import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public final class NotificationsModel: ObservableObject {
    @Published public final var notifications: [NotificationData] = []
    @Published public final var lastRead: Date? = nil

    init(lastRead: Date?) {
        self.lastRead = lastRead

        loadNotifications()
    }

    private final func loadNotifications() {
        let query = lastRead != nil ? Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("notifications").order(by: "timestamp", descending: true).whereField("timestamp", isGreaterThan: lastRead!) :
            Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("notifications").order(by: "timestamp", descending: true)

        query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }

            snapshot.documentChanges.forEach { diff in
                if diff.type == .added {
                    do {
                        let data = try diff.document.data(as: NotificationData.self)
                        self.notifications.append(data)
                    } catch {
                        print("Error decoding notification: \(error)")
                    }
                }
            }
        }
    }
}

public enum FirebaseNotificationUtils {
    public static func sendNotification(to uid: String, data: NotificationData) {
        do {
            try Firestore.firestore().collection("users").document(uid).collection("notifications").addDocument(from: data)
        } catch {
            print("Error sending notification: \(error)")
        }
    }
}
