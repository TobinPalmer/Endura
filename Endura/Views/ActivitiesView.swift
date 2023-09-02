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

  fileprivate static let loadAmount = 5

  fileprivate func loadActivities() {
    let query = (lastDocument == nil) ?
      Firestore.firestore().collection("activities").order(by: "uploadTime").order(by: "time", descending: true).whereField("uploadTime", isLessThan: lastRefresh).limit(to: ActivitiesViewModel.loadAmount) :
      Firestore.firestore().collection("activities").order(by: "uploadTime").order(by: "time", descending: true).whereField("uploadTime", isLessThan: lastRefresh).limit(to: ActivitiesViewModel.loadAmount).start(afterDocument: lastDocument!)

    query.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error fetching documents: \(error!)")
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

    lastRefresh = Date()

    var listener: ListenerRegistration? = nil

    listener = query.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error fetching documents: \(error!)")
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

      let activity = ActivityData(
        averagePower: data.averagePower,
        calories: data.calories,
        comments: data.comments,
        distance: data.distance,
        description: data.description,
        duration: data.duration,
        likes: data.likes,
        type: data.type,
        startCity: data.startCity,
        startLocation: data.startLocation,
        time: data.time,
        title: data.title,
        totalDuration: data.totalDuration,
        uid: data.uid
      )

      if diff.type == .added || diff.type == .modified {
        activities.updateValue((diff.document.documentID, activity), forKey: diff.document.documentID)
      } else if diff.type == .removed {
        activities.removeValue(forKey: diff.document.documentID)
      }
    } catch {
      print("Error decoding activity: \(error)")
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
            ForEach(activityViewModel.activities.values.sorted(by: { $0.1.time > $1.1.time }), id: \.0) { id, activity in
              ActivityPost(id: id, activity: activity)
                .onAppear {
                  if id == activityViewModel.activities.values.sorted(by: { $0.1.time > $1.1.time }).last?.0 && activityViewModel.activities.count >= ActivitiesViewModel.loadAmount {
                    activityViewModel.loadActivities()
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
          activityViewModel.loadNewActivities()
        }
    }
      .background(Color(.secondarySystemBackground))
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          NavigationLink(destination: NewActivityView()) {
            Image(systemName: "plus")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: NotificationsView()) {
            Image(systemName: "bell")
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
