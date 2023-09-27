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
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    DailySummaryGraph()
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

            Text(response ?? "no response yet").task {
                let palmClient = GenerativeLanguage(apiKey: ProcessInfo.processInfo.environment["PALM_API_KEY"]!)
                do {
                    print("Sending message")
                    let prompt = "What ai are you? Can you tell me about yourself?"

                    let response = try await palmClient.generateText(with: prompt)
                    print("Got response \(response)")

                    if let candidate = response.candidates?.first, let text = candidate.output {
                        self.response = text
                    }
                } catch {
                    print("Error with palm response: \(error)")
                }
            }

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
