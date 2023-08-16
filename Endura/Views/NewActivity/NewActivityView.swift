//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import HealthKit
import SwiftUI

@MainActor final class UploadsViewModel: ObservableObject {
    @Published fileprivate final var uploads: [HKWorkout?] = []
    private var offset: Int = 0

    fileprivate final func activityToIcon(activityName: String) -> String {
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

    fileprivate final func getActivities(_ limitTo: Int) async {
        guard limitTo > 0 else {
            return
        }

        guard uploads.count > limitTo else {
            do {
                let workouts = try await HealthKitUtils.getListOfWorkouts(limitTo: limitTo, offset: offset)
                uploads.append(contentsOf: workouts)
                offset += workouts.count
            } catch {
                print("Error: \(error)")
            }
            return
        }
    }
}

struct NewActivityView: View {
    @EnvironmentObject private var navigation: NavigationModel
    @ObservedObject private var uploadsViewModel = UploadsViewModel()
    @State private var totalItemsLoaded: Int = 0
    @State private var activityEndDatesToUUIDs: [Date: UUID] = [:]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(uploadsViewModel.uploads.compactMap {
                    $0
                }, id: \.self) { activity in
                    Button(action: {}) {
                        let workoutType = activity.workoutActivityType.name
                        let workoutDistance = activity.totalDistance?.doubleValue(for: .mile()) ?? 0.0
                        NavigationLink(destination: PreviewWorkoutView(workout: activity)) {
                            HStack {
                                Image(systemName: uploadsViewModel.activityToIcon(activityName: workoutType))
                                Text(activity.startDate, style: .date)
                                if let distance = activity.totalDistance {
                                    Text(String(describing: distance.doubleValue(for: .mile())))
                                }

                                Text(workoutType)
                            }
                        }
                    }
                    .task {
                        let earliestDate = activityEndDatesToUUIDs.keys.min() ?? Date()
                        activityEndDatesToUUIDs[activity.startDate] = activity.uuid
                        if activity.uuid == activityEndDatesToUUIDs[activity.startDate] {
                            totalItemsLoaded += 10
                            await uploadsViewModel.getActivities(10)
                        }
                    }
                }
            }
        }
        .task {
            await uploadsViewModel.getActivities(1_000_000)
        }
    }
}
