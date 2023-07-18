// // Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var navigation: NavigationModel;
    @State private var user: UserData?

    var body: some View {
        VStack {
            Text("Home Page")
            Text(user?.name ?? "Nil")
            Button("Go To Login") {
                navigation.currentView = .LOGIN
            }
        }
            .task {
                await loadUserData()
            }
    }

    func loadUserData() async {
        do {
            self.user = try await Database.instance.getUserData(userId: "ieq1lE7hNPemjjQfMGpBVMtFkKW2")
        } catch {
            print("Error")
        }
    }
}

struct ActivityPreview: View {
    var body: some View {
        HomeView()
            .environmentObject(NavigationModel.instance)
    }
}