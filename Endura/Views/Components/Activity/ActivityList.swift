import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import HealthKit
import Inject
import SwiftUI

@MainActor public final class ActivityListModel: ObservableObject {
    @Published fileprivate var activities: [String: (String, ActivityData)] = [:]
    @Published var lastDocument: DocumentSnapshot? = nil
    @Published private var lastRefresh = Date()
    @Published public var uids: [String]? = nil

    @Published public var newActivities: [String] = []

    fileprivate static let loadAmount = 5

    fileprivate func clearActivities() {
        activities = [:]
        lastDocument = nil
    }

    fileprivate func loadActivities() {
        var query = Firestore.firestore().collection("activities")
            .order(by: "time", descending: true)
            .whereField("uid", in: uids ?? [])
            .limit(to: ActivityListModel.loadAmount)

        if uids != [AuthUtils.getCurrentUID()] {
            query = query.whereField("visibility", isEqualTo: ActivityVisibility.friends.rawValue)
        }

        query = (lastDocument == nil) ?
            query :
            query.start(afterDocument: lastDocument!)

        var firstLoad = true

        query.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                Global.log.error("Error fetching documents: \(error!)")
                return
            }

            snapshot.documentChanges.forEach { diff in
                self.handleActivityDocument(diff: diff)
                if !firstLoad {
                    if diff.type == .added && !self.newActivities.contains(diff.document.documentID) {
                        print("New activity!")
                        self.newActivities.append(diff.document.documentID)
                    }
                }
            }

            firstLoad = false

            self.lastDocument = snapshot.documents.last
        }
    }

//    fileprivate func loadNewActivities() {
//        var query = Firestore.firestore().collection("activities")
//            .order(by: "uploadTime")
//            .order(by: "time", descending: true)
//            .whereField("uploadTime", isGreaterThan: lastRefresh)
//            .whereField("uploadTime", isLessThan: Date())
//            .whereField("uid", in: uids ?? [])
//
//        if uids != [AuthUtils.getCurrentUID()] {
//            query = query.whereField("visibility", isEqualTo: ActivityVisibility.friends.rawValue)
//        }
//
//        lastRefresh = Date()
//
//        var listener: ListenerRegistration? = nil
//
//        listener = query.addSnapshotListener { querySnapshot, error in
//            guard let snapshot = querySnapshot else {
//                Global.log.error("Error fetching documents: \(error!)")
//                return
//            }
//
//            if snapshot.documentChanges.isEmpty {
//                if let listener = listener {
//                    listener.remove()
//                }
//                return
//            }
//
//            snapshot.documentChanges.forEach { diff in
//                self.handleActivityDocument(diff: diff)
//            }
//        }
//    }

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
    @EnvironmentObject var activityViewModel: ActivityListModel

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
//                                    print("Is focused: \(activityViewModel.isFocused)")
//                                    if activityViewModel.newActivities.contains(id) && activityViewModel.isFocused {
//                                        print("Viewed")
//                                        activityViewModel.newActivities.removeAll(where: { $0 == id })
//                                    }
                                    if id == activityViewModel.activities.values
                                        .sorted(by: { $0.1.time > $1.1.time })
                                        .last?.0 && activityViewModel.activities.count >= ActivityListModel
                                        .loadAmount
                                    {
                                        activityViewModel.loadActivities()
                                    }
                                }
                                .onDisappear {
                                    if activityViewModel.newActivities.contains(id) {
                                        activityViewModel.newActivities.removeAll(where: { $0 == id })
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
        .onAppear {
            activityViewModel.newActivities.removeAll()
        }
        .scrollIndicators(fullWidth ? .automatic : .hidden)
        .refreshable {
//                if singlePerson != nil {
//                    activityViewModel.loadNewActivities()
//                    return
//                }
//                if let friends = activeUserModel.data?.friends {
//                    if activityViewModel.uids != friends {
//                        var uids = [AuthUtils.getCurrentUID()]
//                        uids.append(contentsOf: friends)
//                        activityViewModel.uids = uids
//                        activityViewModel.clearActivities()
//                        activityViewModel.loadActivities()
//                        return
//                    }
//                }
//                activityViewModel.loadNewActivities()
        }
        .onAppear {
            if singlePerson != nil {
                activityViewModel.uids = [singlePerson!]
            } else {
                if let friends = activeUserModel.data?.friends {
                    var uids = [AuthUtils.getCurrentUID()]
                    uids.append(contentsOf: friends)
                    activityViewModel.uids = uids
                }
            }
            activityViewModel.loadActivities()
        }
    }
}
