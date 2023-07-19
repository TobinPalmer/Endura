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
    @State private var activities: [Activity] = []
    @State private var uploads: [HKWorkout?] = []

    var body: some View {
        VStack(content: {
//            List(activities, id: \.self) { activity in
//                Text("\(activity.distance)")
//            }
//            Text(String(describing: uploads))
            List($uploads, id: \.self) { activity in
                Text(String(describing: activity))
            }
        })
            .onAppear {
                getActivities()
            }
    }

    func getActivities() {
        HealthKitUtils.getListOfWorkouts(limitTo: 100) { result in
            switch result {
            case .success(let workouts):
                print("success")
                self.uploads = workouts
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    func getListOfWorkouts() async {
        do {
            self.activities = try await WorkoutUtils.getActivity()
        } catch {
            print("Activity error: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
