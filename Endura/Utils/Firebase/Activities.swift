import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import Foundation

public enum ActivityUtils {
    public static func getActivityRouteData(id: String) async -> ActivityRouteData {
        print("Getting activity route data...", id)
        do {
            let routeData = try await Firestore.firestore().collection("activities").document(id).collection("data").document("data").getDocument(as: ActivityRouteData.self)
            return routeData
        } catch {
            print("Error getting activity route data: \(error)")
            return ActivityRouteData(
                graphData: [],
                graphInterval: 0,
                routeData: []
            )
        }
    }

    public static func toggleLike(id: String, activity: ActivityData) {
        let uid = AuthUtils.getCurrentUID()
        Firestore.firestore().collection("activities").document(id).updateData([
            "likes": activity.likes.contains(uid) ? FieldValue.arrayRemove([uid]) : FieldValue.arrayUnion([uid]),
        ])
    }

    public static func addComment(id: String, comment: ActivityCommentData) {
        Firestore.firestore().collection("activities").document(id).updateData([
            "comments": FieldValue.arrayUnion([[
                "uid": comment.uid,
                "message": comment.message,
                "time": comment.time,
            ] as [String: Any]]),
        ])
    }

    public static func deleteActivity(id: String) {
        Firestore.firestore().collection("activities").document(id).delete()
    }

    public static func uploadActivity(activity: ActivityDataWithRoute, image: UIImage? = nil) async throws {
        do {
            let activityDoc = try Firestore.firestore().collection("activities").addDocument(from: activity.getDataWithoutRoute())
            try activityDoc.collection("data").document("data").setData(from: activity.data)

            guard let image else {
                return
            }
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("activities/\(activityDoc.documentID)/map")
            let data = image.pngData()
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            guard let data = data else {
                print("Error getting image data")
                return
            }
            imageRef.putData(data, metadata: metadata) { metadata, error in
                guard let metadata = metadata else {
                    print("Error uploading image: \(error!)")
                    return
                }
                print("Image uploaded successfully")
            }
        } catch {
            print("Error uploading workout: \(error)")
        }
    }
}
