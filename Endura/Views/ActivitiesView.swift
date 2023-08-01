//
// Created by Brandon Kirbyson on 7/28/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import HealthKit

@MainActor fileprivate final class ActivitiesViewModel: ObservableObject {
    @Published fileprivate var activities: [String: ActivityData] = [:]
    @Published var lastActivityDate: Date? = nil

    @Published var loadIndex = 0

    private static let loadAmount = 4

    fileprivate func loadActivities() async {
        loadIndex += 1

        let baseQuery = Firestore.firestore().collection("activities").order(by: "time", descending: true).limit(to: ActivitiesViewModel.loadAmount)

        let query = (loadIndex == 0 || lastActivityDate == nil) ? baseQuery : baseQuery.start(after: [lastActivityDate!])
        print(loadIndex, lastActivityDate)

        query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }

            snapshot.documentChanges.forEach {
                (diff: DocumentChange) in
                if (diff.type == .added || diff.type == .modified) {
                    do {
                        let data = try diff.document.data(as: ActivityData.self)
                        let activity = ActivityData(
                                uid: data.uid,
                                time: data.time,
                                distance: data.distance,
                                duration: data.duration,
                                comments: [],
                                likes: []
                        )

                        if (self.lastActivityDate == nil) {
                            self.lastActivityDate = data.time
                        } else if data.time < self.lastActivityDate! {
                            self.lastActivityDate = data.time
                        }

                        print("id", diff.document.documentID)
                        self.activities.updateValue(activity, forKey: diff.document.documentID)
                        self.activities = self.activities
                        print("activity added", self.activities.count)
                    } catch {
                        print("Error decoding activity: \(error)")
                    }
                } else if (diff.type == .removed) {
                    self.activities.removeValue(forKey: diff.document.documentID)
                }
            }
        }
    }

    func initActivity() async {
        await loadActivities()
    }

}

struct ActivitiesView: View {
    @StateObject fileprivate var activityViewModel = ActivitiesViewModel()

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                Text(String(activityViewModel.activities.count))
                if (activityViewModel.activities.count > 0) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 1), spacing: 20) {
                        ForEach(activityViewModel.activities.keys.sorted(by: >), id: \.self) { key in
                            if let activity = activityViewModel.activities[key] {
                                ActivityPost(id: key, activity: activity)
                                    .task {
                                        if activity.time == activityViewModel.lastActivityDate {
                                            print("Loading more posts from task")
                                            await activityViewModel.loadActivities()
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
//                .onAppear {
//                    activityViewModel.getActivities(loadIndex: 1)
//                }
        }
            .task {
                await activityViewModel.initActivity()
            }
            .background(Color(.secondarySystemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: NewActivityView()) {
                        Image(systemName: "plus")
                            .font(.title)
                    }
                }
            }
    }
}
