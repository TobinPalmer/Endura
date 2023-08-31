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
            WeeklySummaryGraph(
                [
                    WeeklyGraphData(day: 1, distance: 5),
                    WeeklyGraphData(day: 2, distance: 4),
                    WeeklyGraphData(day: 3, distance: 5),
                ]
            )
        }
    }
}

class DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        InjectedContentView()
    }

    #if DEBUG
        @objc class func injected() {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.rootViewController =
                UIHostingController(rootView: InjectedContentView())
        }
    #endif
}
