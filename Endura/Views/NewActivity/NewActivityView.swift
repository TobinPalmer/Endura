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

  var body: some View {
    if !HealthKitUtils.isAuthorized() {
      Text("Please authorize Apple Health to continue.")
      Button("Authorize") {
        HealthKitUtils.requestAuthorization()
      }
    }
    List(uploadsViewModel.uploads, id: \.self) { activity in
      if let activity {
        NavigationLink(destination: PreviewWorkoutView(workout: activity)) {
          let workoutType = activity.workoutActivityType.name
          let workoutDistance = (activity.totalDistance?.doubleValue(for: .mile()) ?? 0.0).rounded(toPlaces: 2).removeTrailingZeros()
          HStack {
            if ActivityUtils.isActivityUploaded(activity) {
              Image(systemName: "checkmark").font(.largeTitle).foregroundColor(.green)
            } else {
              Image(systemName: uploadsViewModel.activityToIcon(activityName: workoutType)).font(.largeTitle)
            }
            Text(activity.startDate, style: .date)
            Text("• \(workoutDistance) mi")
          }
        }
      }
    }
      .task {
        await uploadsViewModel.getActivities(100)
      }
  }
}
