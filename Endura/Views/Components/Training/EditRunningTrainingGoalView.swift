import Foundation
import SwiftUI
import SwiftUICalendar

struct EditRunningTrainingGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State var goal: RunningTrainingGoalData

    var body: some View {
        VStack {
            switch goal.workout {
            case .open:
                Text("Open Workout")
            case let .distance(distance):
                EditDistanceWorkoutGoal(workout: $goal.workout)
            case let .time(time):
                Text("Time: \(time)")
            case let .pacer(distance, time):
                Text("Distance: \(distance)")
                Text("Time: \(time)")
            case let .custom(data):
                Text("Custom Workout")
            }
        }
        .onChange(of: goal) { _, newValue in
            activeUser.training.updateTrainingGoal(goal.date.toYearMonthDay(), TrainingGoalData.run(data: newValue))
        }
    }
}

private struct EditDistanceWorkoutGoal: View {
    @Binding var workout: WorkoutGoalData
    @State var distance: Double = 0

    init(workout: Binding<WorkoutGoalData>) {
        _workout = workout
        if case let .distance(distance) = workout.wrappedValue {
            _distance = State(initialValue: distance)
        }
    }

    var body: some View {
        Text("Distance: \(distance)")
        Stepper("Distance", value: $distance, in: 0 ... 100)
            .onChange(of: distance) { _, newValue in
                workout = .distance(distance: newValue)
            }
    }
}
