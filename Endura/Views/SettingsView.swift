//
// Created by Brandon Kirbyson on 7/31/23.
//

import Foundation
import SwiftUI

public struct SettingsView: View {
    public var body: some View {
        VStack {
            Text("Settings").font(.title)

            List {
                NavigationLink(destination: AccountSettingsView()) {
                    Label("Account", systemImage: "person")
                }
                NavigationLink(destination: Text("Friends")) {
                    Label("Friends", systemImage: "person.2")
                }
                NavigationLink(destination: Text("Notifications")) {
                    Label("Notifications", systemImage: "bell")
                }
                NavigationLink(destination: Text("Privacy")) {
                    Label("Privacy", systemImage: "lock")
                }
                NavigationLink(destination: Text("About")) {
                    Label("About", systemImage: "info.circle")
                }
            }
        }
    }
}