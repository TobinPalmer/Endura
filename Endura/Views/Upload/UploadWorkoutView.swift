//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

@MainActor class UploadsViewModel: ObservableObject {
    @Published var uploads: [HKWorkout?] = []

    public func setWorkouts(workouts: [HKWorkout?]) {
        DispatchQueue.main.async {
            self.uploads = workouts
        }
    }
}

struct UploadWorkoutView: View {
    @EnvironmentObject var navigation: NavigationModel
    @State private var activities: [Activity] = []

    @ObservedObject var uploadsViewModel = UploadsViewModel()

    var body: some View {
        List(uploadsViewModel.uploads, id: \.self) { activity in
            let formatter = DateFormatter()
            if let activity = activity {
//                let workoutDate = activity.startDate.formatted()
//                let workoutTime = formatter.string(from: activity.startDate)
                let workoutDuration = activity.duration
                let workoutDistance = activity.totalDistance?.doubleValue(for: .meter())
                let workoutDurationFormatted = TimeUtils.secondsToFormattedTime(seconds: Int(workoutDuration))
//                let workoutType = activity.workoutActivityType.name
//                var values: [[Date: (Double, Double)]?] = []

                let _ = Task {
                    do {
                        let graph = try await HealthKitUtils.getHeartRateGraph(for: activity)
                        graph.flatMap({ $0 }).forEach({ (date, value) in
                            print(date, value)
                        })
                    } catch {
                        print("Error getting heart rate graph")
                    }
                }

                let _ = HealthKitUtils.getWorkoutRoute(workout: activity) { routes, error in
                    guard error == nil else {
                        print("Error getting route", String(describing: error))
                        return
                    }

                    guard let routes = routes else {
                        print("No routes")
                        return
                    }

                    print("Getting locations")
                    Task {
                        routes.forEach({ route in
                            Task {
                                let locations = await HealthKitUtils.getLocationData(for: route)
                                locations.forEach({ location in
                                    print(TimeUtils.convertMpsToMpm(metersPerSec: location.speed))
                                })
                            }
                        })
                    }
                }

                Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")
                NavigationLink(destination: Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")) {
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
        print("Testing", uploadsViewModel.uploads)

        guard uploadsViewModel.uploads.isEmpty == false else {
            do {
                let workouts = try await HealthKitUtils.getListOfWorkouts(limitTo: 1)
                uploadsViewModel.setWorkouts(workouts: workouts)
            } catch {
                print("Error: \(error)")
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
