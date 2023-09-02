import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public enum FirebaseNotificationUtils {
    public static func sendNotification(to uid: String, data: NotificationData) {
        do {
            try Firestore.firestore().collection("users").document(uid).collection("notifications").addDocument(from: data)
        } catch {
            print("Error sending notification: \(error)")
        }
    }
}
