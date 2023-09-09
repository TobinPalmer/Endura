import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var activeUser: ActiveUserModel

    var body: some View {
        VStack {
            List {
                Section(header: Text("Account")) {
                    NavigationLink(destination: AccountSettingsView()) {
                        Label("Account", systemImage: "person")
                    }

                    NavigationLink(destination: List {
                        Section(footer: Text("This will disable all notifications from Endura.")) {
                            Toggle(isOn: $activeUser.settings.notifications) {
                                Label("Notifications", systemImage: "bell")
                            }
                        }

                        Section(header: Text("Social")) {
                            Toggle(isOn: $activeUser.settings.notificationsFriendRequest) {
                                Label("Friend Request", systemImage: "person.badge.plus")
                            }
                            Toggle(isOn: $activeUser.settings.notificationsFriendRequestAccepted) {
                                Label("Friend Request Accepted", systemImage: "person.fill.checkmark")
                            }
                            Toggle(isOn: $activeUser.settings.notificationsNewLike) {
                                Label("New Like", systemImage: "hand.thumbsup")
                            }
                            Toggle(isOn: $activeUser.settings.notificationsNewComment) {
                                Label("New Comment", systemImage: "bubble.left")
                            }
                        }

                        Section(header: Text("Training")) {
                            Toggle(isOn: $activeUser.settings.notificationsDailyTrainingPlan) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Label("Daily Training Plan", systemImage: "calendar")
                                    Text("Receive your daily training plan at the start of each day.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Toggle(isOn: $activeUser.settings.notificationsDailySummary) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Label("Daily Summary", systemImage: "checklist.checked")
                                    Text("Receive a summary of your day at the end of each day.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Toggle(isOn: $activeUser.settings.notificationsFinishedActivity) {
                                Label("Finished Activity", systemImage: "figure.run")
                            }
                            Toggle(isOn: $activeUser.settings.notificationsPostRunReminder) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Label("Post Run Reminder", systemImage: "figure.strengthtraining.functional")
                                    Text("Receive a reminder to do your post run exercises after each run.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .navigationBarTitle("Notifications")

                    ) {
                        Label("Notifications", systemImage: "bell")
                    }

                    NavigationLink(destination: List {
                        Section(header: Text("Availability"), footer: Text("This will be used to determine what are the options for your training plan.")) {
                            let options = VStack {
                                Text("Busy").tag(TrainingDayAvailability.busy)
                                Text("Maybe").tag(TrainingDayAvailability.maybe)
                                Text("Free").tag(TrainingDayAvailability.free)
                            }

                            Picker(selection: .constant(TrainingDayAvailability.free), label: Text("Monday"), content: {
                                options
                            })
                            .pickerStyle(.menu)

                            Picker(selection: .constant(TrainingDayAvailability.free), label: Text("Tuesday"), content: {
                                options
                            })
                            .pickerStyle(.menu)
                        }
                    }
                    .navigationBarTitle("Training")
                    ) {
                        Label("Training", systemImage: "calendar")
                    }

                    NavigationLink(destination: VStack {
                        List {
                            Section {
                                Picker(selection: $activeUser.settings.defaultActivityVisibility, label: Text("Default Activity Visibility")) {
                                    Text("Everyone").tag(ActivityVisibility.everyone)
                                    Text("Friends").tag(ActivityVisibility.friends)
                                    Text("Private").tag(ActivityVisibility.none)
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
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle("Settings", displayMode: .large)
    }
}
