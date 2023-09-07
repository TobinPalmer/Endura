import Foundation
import SwiftUI

struct ProgressDashboardView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: AccountSettingsView()) {
                Text("Account View")
            }

            NavigationLink(destination: PostRunView()) {
                Text("Post Run")
            }
        }
    }
}
