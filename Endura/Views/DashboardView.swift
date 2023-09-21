import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import HealthKit
import Inject
import RiveRuntime
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var notificationsModel: NotificationsModel

    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    WeeklySummaryGraph(
                        [
                            WeeklyGraphData(day: .monday, distance: 5),
                            WeeklyGraphData(day: .monday, distance: 5),
                            WeeklyGraphData(day: .monday, distance: 5),
                            WeeklyGraphData(day: .wednesday, distance: 10),
                            WeeklyGraphData(day: .sunday, distance: 2),
                        ]
                    )
                    .padding()
                }
                .frame(minWidth: 0, maxWidth: .infinity)

                HStack(spacing: 10) {
                    VStack {
                        GoalRing(.distance)
                            .frame(maxHeight: 70)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                    .background(.red)
                    .cornerRadius(8)

                    VStack {
                        GoalRing(.distance)
                            .frame(maxHeight: 70)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                    .background(.orange)
                    .cornerRadius(8)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }

            Text("Hello world")

            VStack {
                RiveViewModel(
                    fileName: "pointandclick"
                ).view()
            }
            .frame(width: 200, height: 200)

            TrainingGoalList()
        }
        .padding(5)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: NewActivityView()) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: NotificationsView()) {
                    Image("bell")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .overlay(
                            NotificationCountView(value: $notificationsModel.unreadCount)
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

class DashboardView_Previews: PreviewProvider {
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
