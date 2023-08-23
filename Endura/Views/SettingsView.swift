import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var activeUser: ActiveUserModel

    var body: some View {
        VStack {
            VStack {
                List {
                    Section(header: Text("Account")) {
                        Toggle(isOn: $activeUser.settings.notifications) {
                            Label("Push Notifications", systemImage: "bell")
                        }

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
                }
                .frame(maxHeight: .infinity)

                Button(action: {
                    AuthUtils.logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
