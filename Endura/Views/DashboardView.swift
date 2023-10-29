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

            VStack {
                let color = activeUserModel.training.getTrainingDay(.current).type.getColor()
                LinearGradient(
                    gradient: Gradient(colors: [
                        color,
                        color.opacity(0.9),
                        color.opacity(0.7),
                        color.opacity(0.3),
                        Color("Background"),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .frame(height: 300)
                Spacer()
            }

            ScrollView {
                VStack(spacing: 20) {
                    Text("\(FormattingUtils.fullFormattedDay(.current))")
                        .alignFullWidth()
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextLight"))
                        .padding(.vertical, 6)

                    DailySummaryGraph()
                        .frame(height: 200)

                    TrainingGoalList()

                    TrainingGoalList(selectedDate: .constant(.current.addDay(value: 1)))
                }
                .enduraPadding()
            }
            .toolbarBackground(activeUserModel.training.getTrainingDay(.current).type.getColor())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    UserProfileLink(AuthUtils.getCurrentUID()) {
                        HStack {
                            ProfileImage(AuthUtils.getCurrentUID(), size: 30)
                            Text("Hi, \(activeUserModel.data.name)")
                                .font(.body)
                                .foregroundColor(Color("TextLight"))
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NotificationsView()) {
                        Image(systemName: "bell")
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextLight"))
                            .overlay(NotificationCountView(value: $notificationsModel.unreadCount))
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
