//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

class UploadsViewModel: ObservableObject {
    @Published var uploads: [HKWorkout?] = []
}

struct UploadWorkoutView: View {
    @EnvironmentObject var navigation: NavigationModel
    @State private var activities: [Activity] = []
    @ObservedObject var uploadsViewModel = UploadsViewModel()

    var body: some View {
        Text("Upload Workout")
            .padding(.horizontal, 15)

        List(uploadsViewModel.uploads, id: \.self) { activity in
            let formatter = DateFormatter()
            if let activity = activity {
                let workoutDate = activity.startDate.formatted() ?? ""
                let workoutTime = formatter.string(from: activity.startDate ?? Date())
                let workoutDuration = activity.duration ?? 0.0
                let workoutDistance = activity.totalDistance?.doubleValue(for: .meter())
                let workoutDurationFormatted = TimeUtils.secondsToFormattedTime(seconds: Int(workoutDuration))
                let workoutType = activity.workoutActivityType.name ?? ""
//                var values: [[Date: (Double, Double)]?] = []
                Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")
            } else {
                Text("No activity")
            }

//            let _ = HealthKitUtils.getHeartRateGraph(for: activity.wrappedValue!) { result in
//                switch result {
//                case .success(let graph):
//                    print("It worked")
//                    values = graph
//                case .failure(let error):
//                    print(error)
//                }
//            }
//
//            Text(String(describing: values))
//            Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")
        }
            .onAppear {
                getActivities()
            }
    }

    func getActivities() {
        print("Testing", uploadsViewModel.uploads)

        guard uploadsViewModel.uploads.isEmpty == false else {
            HealthKitUtils.getListOfWorkouts(limitTo: 10000) { result in
                print("NOT Using cached workouts")
                switch result {
                case .success(let workouts):
                    uploadsViewModel.uploads = workouts
                    print("cool", uploadsViewModel.uploads)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            return
        }

        print("Using cached workouts")
    }

    func getListOfWorkouts() async {
        do {
            self.activities = try await WorkoutUtils.getActivity()
        } catch {
            print("Activity error: \(error)")
        }
    }
}
