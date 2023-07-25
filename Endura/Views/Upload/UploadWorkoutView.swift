//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

@MainActor final class UploadsViewModel: ObservableObject {
    @Published fileprivate final var uploads: [HKWorkout?] = []

    final fileprivate func activityToIcon(activityName: String) -> String {
        switch activityName {
        case "Running":
            return "figure.run"
        case "Cycling":
            return "figure.outdoor.cycle"
        case "Walking":
            return "figure.walk"
        case "Swimming":
            return "figure.pool.swim"
        case "Elliptical":
            return "figure.walk"
        case "Other":
            return "figure.walk"
        default:
            return "figure.walk"
        }
    }

    final fileprivate func getActivities() async {
        guard uploads.isEmpty == false else {
            do {
                let workouts = try await HealthKitUtils.getListOfWorkouts(limitTo: 5)
                uploads = workouts
            } catch {
                print("Error: \(error)")
            }
            return
        }
    }
}

public struct UploadWorkoutView: View {
    @EnvironmentObject private var navigation: NavigationModel
    @ObservedObject private var uploadsViewModel = UploadsViewModel()

    public var body: some View {
        VStack {
            ForEach(uploadsViewModel.uploads, id: \.self) { activity in
                Button(action: {}) {
                    if let activity = activity {
                        let workoutType = activity.workoutActivityType.name

                        NavigationLink(destination: PreviewWorkoutView(workout: activity)) {
                            HStack {
                                Image(systemName: uploadsViewModel.activityToIcon(activityName: workoutType))
                                Text(workoutType)
                            }
                        }
                    } else {
                        Text("No Activities")
                    }
                }
            }
        }
                .task {
                    await uploadsViewModel.getActivities()
                }
    }

}
