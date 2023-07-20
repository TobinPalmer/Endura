//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

struct UploadWorkoutView: View {
    @EnvironmentObject var navigation: NavigationModel
    @State private var activities: [Activity] = []
    @State private var uploads: [HKWorkout?] = []

    var body: some View {
        Text("Upload Workout")
        VStack(content: {
            Spacer()
            Text("Dashboard")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading, 20)
            Spacer()
            Image(systemName: "person")
                .font(.title)
                .padding(.trailing, 20);
        })
            .padding(.horizontal, 15)
        List(activities, id: \.self) { activity in
            Text("\(activity.distance)")
        }
        Text(String(describing: uploads))
        List($uploads, id: \.self) { activity in
            let formatter = DateFormatter()
            let workoutDate = activity.wrappedValue?.startDate.formatted() ?? ""
            let workoutTime = formatter.string(from: activity.wrappedValue?.startDate ?? Date())
            let workoutDuration = activity.wrappedValue?.duration ?? 0.0
            let workoutDistance = activity.wrappedValue?.totalDistance?.doubleValue(for: .meter())
            let workoutDurationFormatted = TimeUtils.secondsToFormattedTime(seconds: Int(workoutDuration))
            let workoutType = activity.wrappedValue?.workoutActivityType.name ?? ""
//                Text("\(workoutTime) - \(workoutDistance ?? 0.0) - \(workoutType)")
//                Text("YOU WERE \(workoutType) FOR  \(workoutDistance ?? 0.0) METERS")
            var values: [[Date: (Double, Double)]?] = []

            let _ = HealthKitUtils.getHeartRateGraph(for: activity.wrappedValue!) { result in
                switch result {
                case .success(let graph):
                    print("It worked")
                    values = graph
                case .failure(let error):
                    print(error)
                }
            }

            Text(String(describing: values))
//                Text("\(HealthKitUtils.getHeartRateGraph(for: activity.wrappedValue!))")
            Text("\(workoutDurationFormatted) \(workoutDistance ?? 0.0)")
        }
            .onAppear {
                getActivities()
            }
    }

    func getActivities() {
        HealthKitUtils.getListOfWorkouts(limitTo: 3) { result in
            switch result {
            case .success(let workouts):
                self.uploads = workouts
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    func getListOfWorkouts() async {
        do {
            self.activities = try await WorkoutUtils.getActivity()
        } catch {
            print("Activity error: \(error)")
        }
    }
}
