import FirebaseAuth
import FirebaseFirestore
import Inject
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject private var IO = Inject.observer

    var body: some View {
        switch navigation.currentView {
        case .LOGIN:
            NavigationView {
                LoginView()
            }
        case .HOME:
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
            .enableInjection()
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
