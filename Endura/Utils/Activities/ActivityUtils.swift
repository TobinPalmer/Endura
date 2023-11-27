import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import Foundation
import HealthKit

public enum ActivityUtils {
    public static func getActivityRouteData(id: String) async -> ActivityRouteData {
        do {
            let routeData = try await Firestore.firestore().collection("activities").document(id).collection("data")
                .document("data").getDocument(as: ActivityRouteData.self)
            return routeData
        } catch {
            Global.log.error("Error getting activity route data: \(error)")
            return ActivityRouteData(
                graphData: [],
                graphInterval: 0,
                routeData: []
            )
        }
    }

    public static func toggleLike(id: String, activity: ActivityData) {
        let uid = AuthUtils.getCurrentUID()
        if activity.uid == uid {
            return
        }

        Firestore.firestore().collection("activities").document(id).updateData([
            "social.likes": activity.social.likes.contains(uid) ? FieldValue.arrayRemove([uid]) : FieldValue
                .arrayUnion([uid]),
        ])
    }

    public static func addComment(id: String, comment: ActivityCommentData) {
        Firestore.firestore().collection("activities").document(id).updateData([
            "comments": FieldValue.arrayUnion([[
                "uid": comment.uid,
                "message": comment.message,
                "time": comment.time,
            ]]),
        ])
    }

    public static func deleteActivity(id: String) {
        Firestore.firestore().collection("activities").document(id).delete()
    }

    public static func isActivityUploaded(_ activity: HKWorkout) -> Bool {
        !CacheUtils.fetchListedObject(
            UploadedActivityCache.self,
            predicate: NSPredicate(format: "id == %@", activity.uuid as CVarArg)
        ).isEmpty
    }

    public static func setActivityUploaded(for activity: HKWorkout) {
        let newActivity = UploadedActivityCache(context: CacheUtils.context)
        newActivity.id = activity.uuid
        CacheUtils.addListedObject(newActivity)
    }

    public static func uploadActivity(
        activity: ActivityDataWithRoute,
        image: UIImage? = nil,
        storage: Storage? = nil
    ) async {
        do {
            let documentData = ActivityDocument.getDocument(for: activity, uploadTime: Date())
            let activityDoc = Firestore.firestore().collection("activities").document()
            if let image, let storage {
                await uploadImage(image, for: activityDoc.documentID, storage: storage)
            }
            try await activityDoc.setData(from: documentData)
            try await activityDoc.collection("data").document("data").setData(from: activity.data)

        } catch {
            Global.log.error("Error uploading activity: \(error)")
        }
    }

    private static func uploadImage(_ image: UIImage, for activityDoc: String, storage: Storage) async {
        let imageRef = storage.reference().child("activities/\(activityDoc)/map")

        let data = image.pngData()
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"

        guard let data else {
            Global.log.error("Error getting image data")
            return
        }

        await withCheckedContinuation { continuation in
            imageRef.putData(data, metadata: metadata) { metadata, error in
                guard metadata != nil else {
                    Global.log.error("Error uploading image: \(error!)")
                    return
                }

                continuation.resume()
            }
        }
    }
}
