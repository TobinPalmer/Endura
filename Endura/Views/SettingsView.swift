import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel

    var body: some View {
        VStack {
            List {
//                VStack {
//                    ProfileImage(AuthUtils.getCurrentUID(), size: 128)
//
//                    if let user = databaseCache.getUserData(AuthUtils.getCurrentUID()) {
//                        Text(user.name)
//                            .font(.title)
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                    }
//                }
//                    .background(.clear)

                Section(header: Text("Account")) {
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

                Section {
                    Button {
                        AuthUtils.logout()
                    } label: {
                        Text("Logout").foregroundColor(.red)
                    }
                }
            }
        }
    }
}
