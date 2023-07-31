//
// Created by Brandon Kirbyson on 7/28/23.
//
//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import HealthKit

final class ActivitiesViewModel: ObservableObject {
    @Published var activities: [String: ActivityData] = [:]

    init() {
        Firestore.firestore().collection("activities").order(by: "time").limit(to: 5).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { (diff: DocumentChange) in
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
                        self.activities.updateValue(activity, forKey: diff.document.documentID)
                    } catch {
                        print("Error decoding activity: \(error)")
                    }
                } else if (diff.type == .removed) {
                    self.activities.removeValue(forKey: diff.document.documentID)
                }
            }
        }
    }
}

struct ActivitiesView: View {
    @StateObject var activityViewModel = ActivitiesViewModel()

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                if (!activityViewModel.activities.isEmpty) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 1), spacing: 20) {
                        ForEach(activityViewModel.activities.keys.sorted(by: >), id: \.self) { key in
                            if let activity = activityViewModel.activities[key] {
                                ActivityPost(id: key, activity: activity)
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
                            .font(.title)
                    }
                }
            }
    }
}
