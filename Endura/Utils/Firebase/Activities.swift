//
// Created by Brandon Kirbyson on 7/24/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

public struct ActivityUtils {

    public static func getActivityRouteData(id: String) async -> ActivityRouteData {
        print("Getting activity route data...", id)
        do {
            let routeData = try await Firestore.firestore().collection("activities").document(id).collection("data").document("data").getDocument(as: ActivityRouteData.self)
            return routeData;
        } catch {
            print("Error getting activity route data: \(error)")
            return ActivityRouteData(routeData: [], graphData: [], graphInterval: 0)
        }
    }

    public static func uploadActivity(activity: ActivityDataWithRoute, image: UIImage) async throws {
        do {
//            Firestore.firestore().collection("activities").addDocument(from: activity)

            //save image
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("images/test.png")
            let data = image.pngData()
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            guard let data = data else {
                print("Error getting image data")
                return
            }
            imageRef.putData(data, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    print("Error uploading image: \(error!)")
                    return
                }
                print("Image uploaded successfully!")
            }
        } catch {
            print("Error uploading workout: \(error)")
        }
    }
}