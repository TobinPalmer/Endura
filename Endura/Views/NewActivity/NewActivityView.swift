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
                Global.log.error("Error: \(error)")
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
    @State private var isAuthorized = HealthKitUtils.isAuthorized()

    var body: some View {
        if !isAuthorized {
            Text("Please authorize Apple Health to continue.")
            Button("Authorize") {
                HealthKitUtils.requestAuthorization { success in
                    isAuthorized = success
                    print("setting isAuthorized to \(success)")
                    print("but healthKit is \(HealthKitUtils.isAuthorized())")
                }
            }
        } else {
            let groupedActivities = Dictionary(grouping: uploadsViewModel.uploads.compactMap {
                $0
            }) { workout in
                Calendar.current.startOfDay(for: workout.startDate)
            }
            let sortedKeys = groupedActivities.keys.sorted(by: >)

            if sortedKeys.isEmpty {
                VStack {
                    ZStack {
                        Image(systemName: "nosign")
                            .font(.system(size: 150))
                            .foregroundColor(Color("Text"))
                            .zIndex(1)

                        Image(systemName: "figure.walk")
                            .font(.system(size: 100))
                            .foregroundColor(Color("TextMuted"))
                    }

                    VStack {
                        Text("No activities found.")
                            .foregroundColor(Color("TextMuted"))
                            .font(.title2)

                        Text("Check the Apple Health app to see if you have you have any workouts.")
                            .foregroundColor(Color("TextMuted"))
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                    }
                    .padding(.horizontal, 26)
                }
            }

            List {
                ForEach(sortedKeys, id: \.self) { key in
                    Section(header: Text("\(key.formatted(date: .abbreviated, time: .omitted))")) {
                        ForEach(groupedActivities[key]!, id: \.self) { activity in
                            NavigationLink(destination: UploadWorkoutView(workout: activity)) {
                                let workoutType = activity.workoutActivityType.name
                                let workoutDistance = (activity.totalDistance?.doubleValue(for: .mile()) ?? 0.0)
                                    .rounded(toPlaces: 2).removeTrailingZeros()
                                Label {
                                    Text(
                                        "\(activity.startDate.formatted(date: .omitted, time: .shortened)) • \(workoutDistance) mi"
                                    )
                                } icon: {
                                    if ActivityUtils.isActivityUploaded(activity) {
                                        Image(systemName: "checkmark").font(.title2).foregroundColor(.green)
                                    } else {
                                        Image(systemName: uploadsViewModel.activityToIcon(activityName: workoutType))
                                            .font(.title2)
                                    }
                                }
                            }
                            .frame(height: 30)
                        }
                    }
                }
            }
            .task {
                await uploadsViewModel.getActivities(100)
            }
        }
    }
}
