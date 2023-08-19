//
// Created by Brandon Kirbyson on 7/28/23.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import HealthKit
import SwiftUI

@MainActor private final class ActivitiesViewModel: ObservableObject {
    @Published fileprivate var activities: [String: ActivityData] = [:]
    @Published var lastDocument: DocumentSnapshot? = nil

    private static let loadAmount = 5

    fileprivate func loadActivities() {
        let baseQuery = Firestore.firestore().collection("activities").order(by: "time", descending: true).limit(to: ActivitiesViewModel.loadAmount)

        let query = (lastDocument == nil) ? baseQuery : baseQuery.start(afterDocument: lastDocument!)

        query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }

            snapshot.documentChanges.forEach { diff in
                do {
                    let data = try diff.document.data(as: ActivityData.self)
                    let activity = ActivityData(
                        averagePower: data.averagePower,
                        calories: data.calories,
                        comments: data.comments,
                        distance: data.distance,
                        duration: data.duration,
                        likes: data.likes,
                        startCity: data.startCity,
                        startLocation: data.startLocation,
                        time: data.time,
                        totalDuration: data.totalDuration,
                        uid: data.uid
                    )

                    if diff.type == .added || diff.type == .modified {
                        self.activities.updateValue(activity, forKey: diff.document.documentID)
                    } else if diff.type == .removed {
                        self.activities.removeValue(forKey: diff.document.documentID)
                    }
                } catch {
                    print("Error decoding activity: \(error)")
                }
            }

            self.lastDocument = snapshot.documents.last
        }
    }

    init() {
        loadActivities()
    }
}

struct ActivitiesView: View {
    @StateObject fileprivate var activityViewModel = ActivitiesViewModel()

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                if !activityViewModel.activities.isEmpty {
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 1), spacing: 20) {
                        ForEach(activityViewModel.activities.keys.sorted(by: >), id: \.self) { key in
                            if let activity = activityViewModel.activities[key] {
                                ActivityPost(id: key, activity: activity)
                                    .onAppear {
                                        if key == activityViewModel.activities.keys.sorted(by: >).last {
                                            activityViewModel.loadActivities()
                                        }
                                    }
                            }
                        }
                    }
                    .padding(10)
                } else {
                    Text("No activities")
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: NewActivityView()) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: FindUsersView()) {
                    Image(systemName: "person.2")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                UserProfileLink(AuthUtils.getCurrentUID()) {
                    ProfileImage(AuthUtils.getCurrentUID(), size: 30)
                }
            }
        }
    }
}
