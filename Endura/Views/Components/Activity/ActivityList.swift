import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import HealthKit
import Inject
import SwiftUI

@MainActor private final class ActivityListModel: ObservableObject {
    @Published fileprivate var activities: [String: (String, ActivityData)] = [:]
    @Published var lastDocument: DocumentSnapshot? = nil
    @Published private var lastRefresh = Date()
    @Published public var uids: [String]? = nil

    fileprivate static let loadAmount = 5

    fileprivate func clearActivities() {
        activities = [:]
        lastDocument = nil
    }

    fileprivate func loadActivities() {
        var query = Firestore.firestore().collection("activities")
            .order(by: "uploadTime").order(by: "time", descending: true)
            .whereField("uploadTime", isLessThan: lastRefresh)
            .whereField("uid", in: uids ?? [])
            .limit(to: ActivityListModel.loadAmount)

        if uids != [AuthUtils.getCurrentUID()] {
            query = query.whereField("visibility", isEqualTo: ActivityVisibility.friends.rawValue)
        }

        query = (lastDocument == nil) ?
            query :
            query.start(afterDocument: lastDocument!)

        query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                Global.log.error("Error fetching documents: \(error!)")
                return
            }

            snapshot.documentChanges.forEach { diff in
                self.handleActivityDocument(diff: diff)
            }

            self.lastDocument = snapshot.documents.last
        }
    }

    fileprivate func loadNewActivities() {
        var query = Firestore.firestore().collection("activities")
            .order(by: "uploadTime")
            .order(by: "time", descending: true)
            .whereField("uploadTime", isGreaterThan: lastRefresh)
            .whereField("uploadTime", isLessThan: Date())
            .whereField("uid", in: uids ?? [])

        if uids != [AuthUtils.getCurrentUID()] {
            query = query.whereField("visibility", isEqualTo: ActivityVisibility.friends.rawValue)
        }

        lastRefresh = Date()

        var listener: ListenerRegistration? = nil

        listener = query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                Global.log.error("Error fetching documents: \(error!)")
                return
            }

            if snapshot.documentChanges.isEmpty {
                if let listener = listener {
                    listener.remove()
                }
                return
            }

            snapshot.documentChanges.forEach { diff in
                self.handleActivityDocument(diff: diff)
            }
        }
    }

    private func handleActivityDocument(diff: DocumentChange) {
        do {
            let data = try diff.document.data(as: ActivityDocument.self)

            let activity = data.getActivityData()

            if diff.type == .added {
                activities.updateValue((diff.document.documentID, activity), forKey: diff.document.documentID)
            } else if diff.type == .modified {
                withAnimation {
                    activities.updateValue((diff.document.documentID, activity), forKey: diff.document.documentID)
                }
            } else if diff.type == .removed {
                activities.removeValue(forKey: diff.document.documentID)
            }
        } catch {
            Global.log.error("Error decoding activity: \(error)")
        }
    }
}

struct ActivityList: View {
    @EnvironmentObject var activeUserModel: ActiveUserModel
    @StateObject fileprivate var activityViewModel = ActivityListModel()

    public var singlePerson: String? = nil
    public var fullWidth: Bool = true

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20) {
                if !activityViewModel.activities.isEmpty {
                    LazyVGrid(
                        columns: Array(repeating: .init(.flexible(), spacing: 0), count: 1),
                        spacing: 20
                    ) {
                        ForEach(activityViewModel.activities.values.sorted(by: { $0.1.time > $1.1.time }),
                                id: \.0)
                        { id, activity in
                            ActivityPost(id: id, activity: activity)
                                .onAppear {
                                    if id == activityViewModel.activities.values
                                        .sorted(by: { $0.1.time > $1.1.time })
                                        .last?.0 && activityViewModel.activities.count >= ActivityListModel
                                        .loadAmount
                                    {
                                        activityViewModel.loadActivities()
                                    }
                                }
                        }
                    }
                } else {
                    Text("No activities")
                }
            }
            .padding(.horizontal, fullWidth ? 26 : 8)
            .padding(.vertical, 20)
        }
        .scrollIndicators(fullWidth ? .automatic : .hidden)
        .refreshable {
            if singlePerson != nil {
                activityViewModel.loadNewActivities()
                return
            }
            if let friends = activeUserModel.data?.friends {
                if activityViewModel.uids != friends {
                    activityViewModel.uids = friends
                    activityViewModel.clearActivities()
                    activityViewModel.loadActivities()
                    return
                }
            }
            activityViewModel.loadNewActivities()
        }
        .onAppear {
            if singlePerson != nil {
                activityViewModel.uids = [singlePerson!]
            } else {
                if let friends = activeUserModel.data?.friends {
                    activityViewModel.uids = friends
                }
            }
            activityViewModel.loadActivities()
        }
    }
}
