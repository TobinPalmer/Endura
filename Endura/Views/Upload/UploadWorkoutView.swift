//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

@MainActor final class UploadsViewModel: ObservableObject {
    internal typealias Activity = HKWorkout?
    @Published fileprivate final var uploads: [Activity] = []
    @Published private var heartRateGraph: [HeartRateGraph] = []

    fileprivate func getActivities() async {
        guard uploads.isEmpty == false else {
            do {
                let workouts = try await HealthKitUtils.getListOfWorkouts(limitTo: 100)
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
                await uploadsViewModel.getActivities()
            }
    }

}
