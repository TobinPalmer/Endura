import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import HealthKit
import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Welcome!")

            Button {
                NotificationUtils.sendNotification(title: "Test", body: "Test", date: Date().addingTimeInterval(5))
            } label: {
                Text("Send Notification")
                    .foregroundColor(.red)
            }
        }
    }
}
