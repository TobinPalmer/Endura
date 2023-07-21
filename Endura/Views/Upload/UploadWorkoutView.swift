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

                let route = HealthKitUtils.getWorkoutRoute(workout: activity) { routes, error in
                    guard error == nil else {
                        print("Error getting route", error)
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

//                        let locations = await HealthKitUtils.getLocationData(for: routes[0])
//                        let pace = await HealthKitUtils.calculatePace(for: routes[0])
//                        let firstLocation = timeutils.convertmpstompm(meterspersec: locations[0].speed)
//                        print("Locations: \(firstLocation)")
                    }
                }

                Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")
                NavigationLink(destination: Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")) {
                    Text(String(describing: workoutDistance))
                }
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
            HealthKitUtils.getListOfWorkouts(limitTo: 1) { result in
                print("NOT Using cached workouts")
                switch result {
                case .success(let workouts):
                    uploadsViewModel.setWorkouts(workouts: workouts)
//                    uploadsViewModel.uploads = workouts
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
