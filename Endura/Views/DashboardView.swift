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
    @Published var activities: [String: String] = [:]

    init() {
        Firestore.firestore().collection("activities").order(by: "time").limit(to: 5).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added || diff.type == .modified) {
                    print("New/Updated activity: \(diff.document.data())")
                    self.activities[diff.document.documentID] = diff.document.data()["activity"] as? String
                } else if (diff.type == .removed) {
                    print("Removed city: \(diff.document.data())")
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
                            ActivityPost(activity: viewModel.activities[key] ?? "Fail")
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