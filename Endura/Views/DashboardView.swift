//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct DashboardView: View {
    @State private var activities: [Activity] = []

    var body: some View {
        VStack(content: {
            List(activities, id: \.self) { activity in
                Text("\(activity.distance)")
            }
        })
            .onAppear {
                getActivities()
            }
    }

    func getActivities() {
        Firestore.firestore().collection("activities").order(by: "time", descending: true).limit(to: 5).getDocuments { (querySnapshot, error) in
            if let snapshotDocuments = querySnapshot?.documents {
                for document in snapshotDocuments {
                    do {
                        let activityDocument = try document.data(as: ActivityDocument.self)
                        let activity = Activity(
                            userId: activityDocument.userId, time: activityDocument.time, duration: activityDocument.duration, distance: activityDocument.distance, location: activityDocument.location, likes: [], comments: [])
                        activities.append(activity)
                    } catch let error as NSError {
                        print("error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
