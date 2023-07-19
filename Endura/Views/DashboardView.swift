//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct DashboardView: View {
    @State private var activities: [Activity] = []

    var body: some View {
        VStack(content: {
            List(activities, id: \.self) { activity in
                Text("\(activity.distance)")
            }
        })
            .task {
                await getActivities()
            }
    }

    func getActivities() async {
        do {
            self.activities = try await WorkoutUtils.getActivity()
        } catch {
            print("Activity error: \(error)")
        }
    }
}
