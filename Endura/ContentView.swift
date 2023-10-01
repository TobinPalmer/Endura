import FirebaseAuth
import FirebaseFirestore
import Inject
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var usersCache: UsersCacheModel
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject private var IO = Inject.observer
    @State private var activeUserModel: ActiveUserModel?

    @State private var isLogoutButtonHidden = false

    var body: some View {
        if navigation.currentView == .LOGIN {
            NavigationView {
                LoginView()
                    .preferredColorScheme(.light)
            }
            .preferredColorScheme(.light)
            .onAppear {
                activeUserModel = nil
                isLogoutButtonHidden = false
            }
        } else {
            VStack {
                if let activeUserModel = activeUserModel {
                    TabView {
                        NavigationView {
                            DashboardView()
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
                            activeUserModel = try await ActiveUserModel()
                        } catch {
                            Global.log.error("Error creating activeUserModel \(error)")
                            AuthUtils.logout()
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isLogoutButtonHidden = false
                        }
                    }
                }
            }
            .id(navigation.refreshID)
            .preferredColorScheme(.light)
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
