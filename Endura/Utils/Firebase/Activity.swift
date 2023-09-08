import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public enum ActivityUtils {
    public static func getActivity(limitTo _: Int = 500) async throws -> [ActivityData] {
        var activities: [ActivityData] = []

        let querySnapshot = try await Firestore.firestore().collection("activities").order(by: "time", descending: true).limit(to: 5).getDocuments()

        for document in querySnapshot.documents {
            do {
                let activityDocument = try document.data(as: ActivityDocument.self)
                let activity = ActivityData(
                    uid: activityDocument.userId, time: activityDocument.time, duration: activityDocument.duration, distance: activityDocument.distance, location: activityDocument.location, likes: [], comments: []
                )
                activities.append(activity)
            } catch let error as NSError {
                Global.log.error("Error: \(error.localizedDescription)")
            }
        }

        return activities
    }
}
