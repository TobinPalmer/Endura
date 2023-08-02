//
// Created by Brandon Kirbyson on 7/31/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var body: some View {
//        VStack(spacing: 10) {
//            Text("Settings").font(.title)
//
//            List {
//                NavigationLink(destination: AccountSettingsView()) {
//                    Label("Account", systemImage: "person")
//                }
//                NavigationLink(destination: FriendsSettingsView()) {
//                    Label("Friends", systemImage: "person.2")
//                }
//                NavigationLink(destination: NotificationsSettingsView()) {
//                    Label("Notifications", systemImage: "bell")
//                }
//                NavigationLink(destination: PrivacySettingsView()) {
//                    Label("Privacy", systemImage: "lock")
//                }
//                NavigationLink(destination: AboutSettingsView()) {
//                    Label("About", systemImage: "info.circle")
//                }
//
//                Spacer()
//
//                Button {
//                    AuthUtils.logout()
//                } label: {
//                    Text("Logout").foregroundColor(.red)
//                }
//            }
//        }

        VStack {
            List {
                NavigationLink(destination: AccountSettingsView()) {
                    Label("Account", systemImage: "person")
                }
                NavigationLink(destination: FriendsSettingsView()) {
                    Label("Friends", systemImage: "person.2")
                }
                NavigationLink(destination: NotificationsSettingsView()) {
                    Label("Notifications", systemImage: "bell")
                }
                NavigationLink(destination: PrivacySettingsView()) {
                    Label("Privacy", systemImage: "lock")
                }
                NavigationLink(destination: AboutSettingsView()) {
                    Label("About", systemImage: "info.circle")
                }
            }

            Spacer()

            Button {
                AuthUtils.logout()
            } label: {
                Text("Logout").foregroundColor(.red)
            }
                .padding(20)
        }

    }
}
