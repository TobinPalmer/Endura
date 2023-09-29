import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import HealthKit
import Inject
import SwiftUI

@MainActor private final class ActivitiesViewModel: ObservableObject {
    @Published fileprivate var activities: [String: (String, ActivityData)] = [:]
    @Published var lastDocument: DocumentSnapshot? = nil
    @Published private var lastRefresh = Date()
    @Published public var friends: [String]? = nil

    fileprivate static let loadAmount = 5

    fileprivate func clearActivities() {
        activities = [:]
        lastDocument = nil
    }

    fileprivate func loadActivities() {
        let baseQuery = Firestore.firestore().collection("activities")
            .order(by: "uploadTime").order(by: "time", descending: true)
            .whereField("uploadTime", isLessThan: lastRefresh)
            .whereField("uid", in: [AuthUtils.getCurrentUID()] + (friends ?? []))
            .whereField("visibility", isEqualTo: ActivityVisibility.friends.rawValue)
            .limit(to: ActivitiesViewModel.loadAmount)

        let query = (lastDocument == nil) ?
            baseQuery :
            baseQuery.start(afterDocument: lastDocument!)

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
        let query = Firestore.firestore().collection("activities")
            .order(by: "uploadTime")
            .order(by: "time", descending: true)
            .whereField("uploadTime", isGreaterThan: lastRefresh)
            .whereField("uploadTime", isLessThan: Date())
            .whereField("uid", in: [AuthUtils.getCurrentUID()] + (friends ?? []))
            .whereField("visibility", isEqualTo: ActivityVisibility.friends.rawValue)

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

            if diff.type == .added || diff.type == .modified {
                activities.updateValue((diff.document.documentID, activity), forKey: diff.document.documentID)
            } else if diff.type == .removed {
                activities.removeValue(forKey: diff.document.documentID)
            }
        } catch {
            Global.log.error("Error decoding activity: \(error)")
        }
    }
}

struct ActivitiesView: View {
    @EnvironmentObject var activeUserModel: ActiveUserModel
    @StateObject fileprivate var activityViewModel = ActivitiesViewModel()

    let padding: CGFloat = 20

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack {
                ScrollView(.vertical) {
                    if !activityViewModel.activities.isEmpty {
                        LazyVGrid(
                            columns: Array(repeating: .init(.flexible(), spacing: 0), count: 1),
                            spacing: padding
                        ) {
                            ForEach(activityViewModel.activities.values.sorted(by: { $0.1.time > $1.1.time }),
                                    id: \.0)
                            { id, activity in
                                ActivityPost(id: id, activity: activity)
                                    .onAppear {
                                        if id == activityViewModel.activities.values
                                            .sorted(by: { $0.1.time > $1.1.time })
                                            .last?.0 && activityViewModel.activities.count >= ActivitiesViewModel
                                            .loadAmount
                                        {
                                            activityViewModel.loadActivities()
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, padding)
                    } else {
                        Text("No activities")
                    }
                }
                .refreshable {
                    if let friends = activeUserModel.data?.friends {
                        if activityViewModel.friends != friends {
                            activityViewModel.friends = friends
                            activityViewModel.clearActivities()
                            activityViewModel.loadActivities()
                            return
                        }
                    }
                    activityViewModel.loadNewActivities()
                }
            }
        }
        .onAppear {
            if let friends = activeUserModel.data?.friends {
                activityViewModel.friends = friends
            }
            activityViewModel.loadActivities()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: NewActivityView()) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell")
                        .overlay(
                            NotificationCountView(value: .constant(50))
                        )
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

class ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        InjectedContentView()
    }

    #if DEBUG
        @objc class func injected() {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.rootViewController =
                UIHostingController(rootView: InjectedContentView())
        }
    #endif
}
