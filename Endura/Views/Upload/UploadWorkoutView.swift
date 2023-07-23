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
        ForEach(["a", "b", "c"], id: \.self) { item in
//            NavigationLink(destination: Text("\(item)")) {
//                Text("workoutType \(item)")
//            }
            Button {
                print("Clicked")
            } label: {
                Text("Cool \(item)")
            }
        }
            //        List(uploadsViewModel.uploads, id: \.self) { activity in
            //            if let activity = activity {
            //                let workoutDistance = activity.totalDistance?.doubleValue(for: .meter())
            //                let workoutType = activity.workoutActivityType.name
            //
            ////                NavigationLink(destination: PreviewWorkoutView(workout: activity)) {
            ////                    Text("workoutType \(workoutType) distance \(workoutDistance ?? 0)")
            ////                }
            //                NavigationLink(destination: Text("\(workoutType)")) {
            //                    Text("workoutType \(workoutType) distance \(workoutDistance ?? 0)")
            //                }
            //            } else {
            //                Text("No activity")
            //            }
            //        }
            .task {
                await uploadsViewModel.getActivities()
            }
    }

}
