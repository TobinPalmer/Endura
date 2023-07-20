//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            NavigationView {
                DashboardView()
            }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            TrainingView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Training")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}