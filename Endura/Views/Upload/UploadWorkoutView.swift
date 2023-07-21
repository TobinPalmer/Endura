//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

@MainActor final class UploadsViewModel: ObservableObject {
    internal typealias Activity = HKWorkout?
    @Published fileprivate final var uploads: [Activity] = []

    final public func setWorkouts(workouts: [Activity]) {
        DispatchQueue.main.async {
            self.uploads = workouts
        }
    }
}

public struct UploadWorkoutView: View {
    @EnvironmentObject private var navigation: NavigationModel
    @ObservedObject private var uploadsViewModel = UploadsViewModel()

    @State private var activities: [Activity] = []
    @State private var heartRateGraph: [HeartRateGraph] = []

    public var body: some View {
//        List(uploadsViewModel.uploads, id: \.self) { activity in
//        }
//            let formatter = DateFormatter()
//            if let activity = activity {
////                let workoutDate = activity.startDate.formatted()
////                let workoutTime = formatter.string(from: activity.startDate)
//        let workoutDuration = activity.duration
//        let workoutDistance = activity.totalDistance?.doubleValue(for: .meter())
//        let workoutDurationFormatted = TimeUtils.secondsToFormattedTime(seconds: Int(workoutDuration))
////                let workoutType = activity.workoutActivityType.name
////                var values: [[Date: (Double, Double)]?] = []
//
//                let _ = Task {
//                    do {
//                        let graph = try await HealthKitUtils.getHeartRateGraph(for: activity)
//                        graph.flatMap({ $0 }).forEach({ (date, value) in
//                            print(date, value)
//                        })
//                    } catch {
//                        print("Error getting heart rate graph")
//                    }
//                }
//
//                let _ = HealthKitUtils.getWorkoutRoute(workout: activity) { routes, error in
//                    guard error == nil else {
//                        print("Error getting route", String(describing: error))
//                        return
//                    }
//
//                    guard let routes = routes else {
//                        print("No routes")
//                        return
//                    }
//
//                    print("Getting locations")
//                    Task {
//                        routes.forEach({ route in
//                            Task {
//                                let locations = await HealthKitUtils.getLocationData(for: route)
//                                locations.forEach({ location in
//                                    print(TimeUtils.convertMpsToMpm(metersPerSec: location.speed))
//                                })
//                            }
//                        })
//                    }
//                }
//
//                Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")
//                NavigationLink(destination: Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")) {
//                    Text(String(describing: workoutDistance))
//                }
//            } else {
//                Text("No activity")
//            }
//        }
//            .task
//                await getActivities()
//            }
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
        //
        //        List(uploadsViewModel.uploads, id: \.self) { activity in
        //            if let activity = activity {
        //                let workoutDistance = activity
        //                NavigationLink(destination: PreviewWorkoutView(workout: , heartRateGraph: heartRateGraph)) {
        //                    Text(String(describing: workoutDistance))
        //                }
        //            }
        //        }
    }

    func getActivities() async {
        guard uploadsViewModel.uploads.isEmpty == false else {
            do {
                let workouts = try await HealthKitUtils.getListOfWorkouts(limitTo: 1)
                uploadsViewModel.setWorkouts(workouts: workouts)
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
