//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

@MainActor final class UploadsViewModel: ObservableObject {
    internal typealias Activity = HKWorkout?
    @Published fileprivate final var uploads: [Activity] = []
}

public struct UploadWorkoutView: View {
    @EnvironmentObject private var navigation: NavigationModel
    @ObservedObject private var uploadsViewModel = UploadsViewModel()

    @State private var activities: [Activity] = []
    @State private var heartRateGraph: [HeartRateGraph] = []

    public var body: some View {
        List(uploadsViewModel.uploads, id: \.self) { activity in
            if let activity = activity {
                let workoutDistance = activity.totalDistance?.doubleValue(for: .meter())

                NavigationLink(destination: PreviewWorkoutView(workout: activity)) {
                    Text(String(describing: workoutDistance))
                }
            } else {
                Text("No activity")
            }
        }
            .task {
                await getActivities()
            }
    }

    func getActivities() async {
        guard uploadsViewModel.uploads.isEmpty == false else {
            do {
                let workouts = try await HealthKitUtils.getListOfWorkouts(limitTo: 100)
                uploadsViewModel.uploads = workouts
            } catch {
                print("Error: \(error)")
            }
            return
        }
    }

    func getListOfWorkouts() async -> () {
        do {
            self.activities = try await WorkoutUtils.getActivity()
        } catch {
            print("Activity error: \(error)")
        }
    }
}
