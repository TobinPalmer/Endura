import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import Foundation
import HealthKit

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

    public static func isActivityUploaded(_ activity: HKWorkout) -> Bool {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", activity.uuid as CVarArg)
        do {
            let fetchedActivities = try context.fetch(fetchRequest)
            return !fetchedActivities.isEmpty
        } catch {
            return false
        }
    }

    public static func setActivityUploaded(for activity: HKWorkout) {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.perform {
            let newActivity = Activity(context: context)
            newActivity.id = activity.uuid // or any unique identifier for your activity
            do {
                try context.save()
            } catch {
                // handle the Core Data error
            }
        }
    }

    public static func uploadActivity(activity: ActivityDataWithRoute, image: UIImage? = nil, storage: Storage? = nil) throws {
        do {
            let activityDoc = try Firestore.firestore().collection("activities").addDocument(from: activity)
            try activityDoc.collection("data").document("data").setData(from: activity.data)

            if let image, let storage {
                uploadImage(image, for: activityDoc, storage: storage)
            }

        } catch {
            print("Error uploading workout: \(error)")
        }
    }

    private static func uploadImage(_ image: UIImage, for activityDoc: DocumentReference, storage: Storage) {
        let imageRef = storage.reference().child("activities/\(activityDoc.documentID)/map")

        let data = image.pngData()
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"

        guard let data else {
            print("Error getting image data")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Uploading Image outer")
            imageRef.putData(data, metadata: metadata) { _ in
                print("Uploading Image")
            }
        }

//    imageRef.putData(data, metadata: metadata) { metadata, error in
//
//      guard metadata != nil else {
//        print("Error uploading image: \(error!)")
//        return
//      }
//      print("Image uploaded successfully")
//    }
    }
}
