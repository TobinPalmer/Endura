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
                VStack(spacing: 20) {
//                    TabView {
//                        PageWidgetView {
//                            Text("Hello, World!")
//                        }
//                        PageWidgetView {
//                            DailySummaryGraph()
//                        }
//                        PageWidgetView {
//                            Text("???")
//                        }
//                    }
//                    .frame(height: 250)
//                    .tabViewStyle(.page)
//                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))

                    DailySummaryGraph()
                        .frame(height: 200)

                    TrainingGoalList()
                }
                .enduraPadding()
            }
            .navigationBarTitle(FormattingUtils.fullFormattedDay(.current))
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
