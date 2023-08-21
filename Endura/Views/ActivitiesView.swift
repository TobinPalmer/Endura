import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import HealthKit
import Inject
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
                    var data = try diff.document.data(as: ActivityData.self)
                    // Assuming data.time is of type Date
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: data.time)

                    switch hour {
                    case 0 ..< 12:
                        data.title = "Morning Activity"
                    case 12 ..< 17:
                        data.title = "Lunch Activity"
                    case 17 ..< 24:
                        data.title = "Evening Activity"
                    default:
                        data.title = "Activity"
                    }

                    let activity = ActivityData(
                        averagePower: data.averagePower,
                        calories: data.calories,
                        comments: data.comments,
                        distance: data.distance,
                        description: data.description,
                        duration: data.duration,
                        likes: data.likes,
                        startCity: data.startCity,
                        startLocation: data.startLocation,
                        time: data.time,
                        title: data.title,
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
            .refreshable {
                // TODO: Reload the activities (Including map images)
                print("Refreshing")
            }
        }
        .enableInjection()
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
