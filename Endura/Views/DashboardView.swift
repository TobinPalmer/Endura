import Foundation
import GoogleGenerativeAI
import Inject
import RiveRuntime
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var notificationsModel: NotificationsModel
    @EnvironmentObject var activeUserModel: ActiveUserModel

    @State var response: String?

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                VStack {
                    HStack {
                        ForEach(activeUserModel.data.friends, id: \.self) { friend in
                            UserProfileLink(friend) {
                                ProfileImage(friend, size: 50)
                            }
                        }
                        NavigationLink(destination: FindUsersView()) {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Circle())
                                .frame(width: 50, height: 50)
                        }
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()

                    VStack(alignment: .leading) {
                        DailySummaryGraph()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)

//                    HStack(spacing: 10) {
//                        VStack {
//                            GoalRing(.distance)
//                                .frame(maxHeight: 70)
//                        }
//                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
//                            .background(.red)
//                            .cornerRadius(8)
//
//                        VStack {
//                            GoalRing(.distance)
//                                .frame(maxHeight: 70)
//                        }
//                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
//                            .background(.orange)
//                            .cornerRadius(8)
//                    }
//                        .frame(minWidth: 0, maxWidth: .infinity)
                }

                TrainingGoalList()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell")
                        .overlay(
                            NotificationCountView(value: $notificationsModel.unreadCount)
                        )
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
