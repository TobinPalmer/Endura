import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import HealthKit
import Inject
import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Welcome to the app!")

            Button {
                NotificationUtils.sendNotification(title: "Test", body: "Test", date: Date().addingTimeInterval(5))
            } label: {
                Text("Send Notification")
                    .foregroundColor(.red)
            }
        }
        .enableInjection()
    }
}

class DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NavigationModel.instance).environmentObject(DatabaseCacheModel())
    }

    #if DEBUG
        @objc class func injected() {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.rootViewController =
                UIHostingController(rootView: ContentView().environmentObject(NavigationModel.instance).environmentObject(DatabaseCacheModel()))
        }
    #endif
}
