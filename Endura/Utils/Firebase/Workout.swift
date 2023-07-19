//
//  Workout.swift
//  Endura
//
//  Created by Tobin Palmer on 7/18/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct WorkoutUtils {
    public static func getActivity(limitTo: Int = 5) async throws -> [Activity] {
        var activities: [Activity] = []

        let querySnapshot = try await Firestore.firestore().collection("activities").order(by: "time", descending: true).limit(to: 5).getDocuments()

        for document in querySnapshot.documents {
            do {
                let activityDocument = try document.data(as: ActivityDocument.self)
                let activity = Activity(
                    userId: activityDocument.userId, time: activityDocument.time, duration: activityDocument.duration, distance: activityDocument.distance, location: activityDocument.location, likes: [], comments: [])
                activities.append(activity)
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }

        return activities
    }

}
