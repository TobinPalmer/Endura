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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .enduraPadding()
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
        VStack {
            HStack {
                Button(action: {
                    distance -= 1
                }) {
                    Image(systemName: "minus")
                }
                TextField("Distance", value: $distance, format: .number)
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .fontColor(.primary)
                Button(action: {
                    distance += 1
                }) {
                    Image(systemName: "plus")
                }
            }
            .font(.largeTitle)
            .fontWeight(.bold)
            .enduraDefaultBox()
            .onChange(of: distance) { _, newValue in
                workout = .distance(distance: newValue)
            }
        }
        .padding(26)
    }
}
