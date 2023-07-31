//
//  ContentView.swift
//  Endura
//
//  Created by Tobin Palmer on 7/15/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var navigation: NavigationModel;
    @EnvironmentObject var activeUserModel: ActiveUserModel;

    var body: some View {
        switch (navigation.currentView) {
        case .LOGIN:
            LoginView()
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
                .task {
                    await activeUserModel.getData()
                }
        }
    }
}
