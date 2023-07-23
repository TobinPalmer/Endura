//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import HealthKit

final class DashboardViewModel: ObservableObject {
    @Published var activities: [String: ActivityData] = [:]

    init() {
        Firestore.firestore().collection("activities").order(by: "time").limit(to: 5).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                print(diff)
                if (diff.type == .added || diff.type == .modified) {
                    do {
//                        let data = try diff.document.data(as: ActivityData.self)
//                        let activity = ActivityData(
//                                uid: data.uid,
//                                time: data.time,
//                                duration: data.duration,
//                                distance: data.distance,
//                                routeData: [],
//                                likes: [],
//                                comments: []
//                        )
//                        self.activities.updateValue(activity, forKey: diff.document.documentID)
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

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                if (!viewModel.activities.isEmpty) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 1), spacing: 20) {
                        ForEach(viewModel.activities.keys.sorted(by: >), id: \.self) { key in
                            if let activity = viewModel.activities[key] {
                                ActivityPost(activity: activity)
                            }
                        }
                    }
                } else {
                    Text("No activities")
                }
            }
        }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: UploadWorkoutsFrameView()) {
                            Image(systemName: "plus")
                                    .font(.title)
                        }
                    }
                }
    }
}
