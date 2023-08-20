import Foundation
import SwiftUI

struct NotificationsSettingsView: View {
    public var body: some View {
        VStack {
            List {
                Section(header: Text("Notifications")) {
                    Toggle(isOn: .constant(true)) {
                        Label("Push Notifications", systemImage: "bell")
                    }

                    Toggle(isOn: .constant(true)) {
                        Label("Email Notifications", systemImage: "envelope")
                    }
                }

                Section(header: Text("Activity Notifications"), footer: Text("Activity notifications are for your own activities.")) {
                    Toggle(isOn: .constant(true)) {
                        Label("Activity Updates", systemImage: "figure.walk")
                    }

                    Toggle(isOn: .constant(true)) {
                        Label("Activity Comments", systemImage: "bubble.left")
                    }

                    Toggle(isOn: .constant(true)) {
                        Label("Activity Likes", systemImage: "heart")
                    }
                }

                Section(header: Text("Training Notifications")) {
                    Toggle(isOn: .constant(true)) {
                        Label("Training Updates", systemImage: "calendar")
                    }

                    Toggle(isOn: .constant(true)) {
                        Label("Training Comments", systemImage: "bubble.left")
                    }

                    Toggle(isOn: .constant(true)) {
                        Label("Training Likes", systemImage: "heart")
                    }
                }

                Section(header: Text("Friend Notifications")) {
                    Toggle(isOn: .constant(true)) {
                        Label("Friend Requests", systemImage: "person.badge.plus")
                    }

                    Toggle(isOn: .constant(true)) {
                        Label("Friend Comments", systemImage: "bubble.left")
                    }

                    Toggle(isOn: .constant(true)) {
                        Label("Friend Likes", systemImage: "heart")
                    }
                }
            }
        }
        .navigationBarTitle("Notifications")
    }
}
