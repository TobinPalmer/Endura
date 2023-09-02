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
                    WeeklyGraphData(day: .monday, distance: 5),
                    WeeklyGraphData(day: .monday, distance: 5),
                    WeeklyGraphData(day: .monday, distance: 5),
                    WeeklyGraphData(day: .wednesday, distance: 10),
                    WeeklyGraphData(day: .sunday, distance: 2),
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
