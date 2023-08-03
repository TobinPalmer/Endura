//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import HealthKit

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
