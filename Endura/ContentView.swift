import FirebaseAuth
import FirebaseFirestore
import Inject
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var usersCache: UsersCacheModel
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject private var IO = Inject.observer
    @StateObject private var activeUserModel = ActiveUserModel()

    @State private var isLogoutButtonHidden = false

    var body: some View {
        switch navigation.currentView {
        case .LOGIN:
            NavigationView {
                LoginView()
                    .preferredColorScheme(.light)
            }
        case .HOME:
            if activeUserModel.settings != nil {
                TabView {
                    NavigationView {
                        DashboardView()
                            .preferredColorScheme(.light)
                    }
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }

                    NavigationView {
                        ActivitiesView()
                    }
                    .tabItem {
                        Image(systemName: "figure.walk")
                        Text("Activity")
                    }

                    NavigationView {
                        TrainingView()
                    }
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Training")
                    }

                    NavigationView {
                        ProgressDashboardView()
                    }
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Progress")
                    }

                    NavigationView {
                        ProfileView()
                    }
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                }
                .environmentObject(activeUserModel)
                .environmentObject(NotificationsModel(lastRead: activeUserModel.data?.lastNotificationsRead))
                .enableInjection()
            } else {
                VStack {
                    ProgressView()
                    Text("Loading...")

                    if !isLogoutButtonHidden {
                        Button("Logout") {
                            AuthUtils.logout()
                            isLogoutButtonHidden = true
                        }
                    }
                }
                .task {
                    do {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isLogoutButtonHidden = false
                        }
                    } catch {
                        print("Error fetching settings: \(error)")
                    }
                }
            }
        }
    }
}

class ContentView_Previews: PreviewProvider {
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
