//
// Created by Tobin Palmer on 8/25/23.
//

import Foundation
import SwiftUI
import HealthKit

fileprivate final class UploadWorkoutViewModel: ObservableObject {
  @Published fileprivate var enduraWorkout: ActivityDataWithRoute?

  @Published fileprivate var geometryRef: GeometryProxy?
  @Published fileprivate var mapRef: (any View)?

  fileprivate final func getEnduraWorkout(_ workout: HKWorkout) async throws -> ActivityDataWithRoute {
    do {
      return try await HealthKitUtils.workoutToActivityDataWithRoute(for: workout)
    } catch {
      throw error
    }
  }
}

struct UploadWorkoutView2: View {
  @StateObject private var uploadWorkoutViewModel = UploadWorkoutViewModel()
  @StateObject private var activityViewModel = ActivityViewModel()
  @State private var workout: HKWorkout

  init(workout: HKWorkout) {
    self.workout = workout
  }

  public var body: some View {
    if let activityData = uploadWorkoutViewModel.enduraWorkout {
      if !activityData.data.routeData.isEmpty {
        VStack {
          GeometryReader { geometry in
            let map =
              ActivityMap(activityData.data.routeData)
                .frame(height: 300)
                .environmentObject(activityViewModel)
            VStack {
              map
            }
              .onAppear {
                uploadWorkoutViewModel.mapRef = map
                uploadWorkoutViewModel.geometryRef = geometry
              }
          }
        }
          .frame(height: 300)
      }
    } else {
      LoadingMap()
    }
  }
}
