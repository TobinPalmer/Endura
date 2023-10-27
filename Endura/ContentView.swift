import FirebaseAuth
import FirebaseFirestore
import Inject
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var usersCache: UsersCacheModel
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject private var IO = Inject.observer
    @State private var activeUserModel: ActiveUserModel?

    @StateObject private var activitiesViewModel = ActivityListModel()

    @State private var isLogoutButtonHidden = false

    @State private var newActivityView = false

    var body: some View {
        if navigation.currentView == .LOGIN {
            NavigationStack {
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
                    ZStack {
                        TabView {
                            NavigationStack {
                                DashboardView()
                            }
                            .tabItem {
                                Image(systemName: "house")
                                Text("Home")
                            }

                            NavigationStack {
                                ActivitiesView()
                                    .environmentObject(activitiesViewModel)
                            }
                            .tabItem {
                                Image(systemName: "figure.walk")
                                Text("Activity")
                            }
                            .badge(activitiesViewModel.newActivities.count)

//                            NavigationStack {
//                                NewActivityView()
//                            }
//                                .tabItem {
//                                    Image(systemName: "plus")
//                                    Text("New")
//                                }

                            NavigationStack {
                                TrainingView()
                            }
                            .tabItem {
                                Image(systemName: "calendar")
                                Text("Training")
                            }

//                        NavigationStack {
//                            ProgressDashboardView()
//                        }
//                        .tabItem {
//                            Image(systemName: "chart.bar")
//                            Text("Progress")
//                        }

                            NavigationStack {
                                ProfileView()
                            }
                            .tabItem {
                                Image(systemName: "person")
                                Text("Profile")
                            }
                        }
                        .environmentObject(activeUserModel)
                        .environmentObject(NotificationsModel(lastRead: activeUserModel.data?
                                .lastNotificationsRead))
                        .enableInjection()
                        VStack {
                            Spacer()
//                            Image(systemName: "plus.circle.fill")
//                                .font(.system(size: 70))
//                                .foregroundColor(.accentColor)
//                                .offset(y: 10)
//                                .background {
//                                    Circle()
//                                        .fill(Color.white)
//                                        .padding(10)
//                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 0)
//                                        .offset(y: 10)
//                                }
//                                .onTapGesture {
//                                    newActivityView = true
//                                }
                        }
                        .sheet(isPresented: $newActivityView) {
                            NavigationStack {
                                NewActivityView()
                            }
                        }
                    }
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
