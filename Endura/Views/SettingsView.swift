import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var activeUser: ActiveUserModel

    var body: some View {
        VStack {
            VStack {
                List {
                    Section(header: Text("Account")) {
                        NavigationLink(destination: AccountSettingsView()) {
                            Label("Account", systemImage: "person")
                        }

                        NavigationLink(destination: VStack {
                            List {
                                Section(footer: Text("This will disable all notifications from Endura.")) {
                                    Toggle(isOn: $activeUser.settings.notifications) {
                                        Label("Notifications", systemImage: "bell")
                                    }
                                }

                                Section(header: Text("Social")) {
                                    Toggle(isOn: .constant(true)) {
                                        Label("Friend Request", systemImage: "person.badge.plus")
                                    }
                                    Toggle(isOn: .constant(true)) {
                                        Label("Friend Request Accepted", systemImage: "person.fill.checkmark")
                                    }
                                    Toggle(isOn: .constant(true)) {
                                        Label("New Like", systemImage: "hand.thumbsup")
                                    }
                                    Toggle(isOn: .constant(true)) {
                                        Label("New Comment", systemImage: "bubble.left")
                                    }
                                }

                                Section(header: Text("Training")) {
                                    Toggle(isOn: .constant(true)) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Label("Daily Training Plan", systemImage: "calendar")
                                            Text("Receive your daily training plan at the start of each day.")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Toggle(isOn: .constant(true)) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Label("Daily Summary", systemImage: "checklist.checked")
                                            Text("Receive a summary of your day at the end of each day.")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Toggle(isOn: .constant(true)) {
                                        Label("Finished Activity", systemImage: "figure.run")
                                    }
                                    Toggle(isOn: .constant(true)) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Label("Post Run Reminder", systemImage: "figure.strengthtraining.functional")
                                            Text("Receive a reminder to do your post run exercises after each run.")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }) {
                            Label("Notifications", systemImage: "bell")
                        }

                        NavigationLink(destination: VStack {
                            List {
                                Section {
                                    Picker(selection: .constant("Public"), label: Text("Default Activity Visibility")) {
                                        Text("Public").tag(0)
                                        Text("Friends").tag(1)
                                        Text("Private").tag(2)
                                    }
                                }
                            }
                        }) {
                            Label("Privacy", systemImage: "lock")
                        }

                        NavigationLink(destination: AboutSettingsView()) {
                            Label("About", systemImage: "info.circle")
                        }
                    }

                    Section {
                        Button(action: {
                            AuthUtils.logout()
                        }) {
                            Text("Logout")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
