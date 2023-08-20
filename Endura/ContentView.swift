import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigation: NavigationModel

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
                    Image(systemName: "figure.run")
                    Text("Activities")
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
        }
    }
}
