import Foundation
import SwiftUI
import SwiftUICalendar

struct AddTrainingGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @Environment(\.dismiss) private var dismiss
    public var selectedDate: YearMonthDay

    @State public var goal: TrainingRunGoalData

    init(_ selectedDate: YearMonthDay) {
        self.selectedDate = selectedDate
        _goal = State(initialValue: TrainingRunGoalData(
            date: selectedDate,
            workout: .open
        ))
    }

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 26) {
                    VStack(spacing: 6) {
                        Text("Add Training Goal")
                            .font(.title)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                            .alignFullWidth()
                        Text("Select a type of goal to add.")
                            .font(.body)
                            .fontColor(.secondary)
                            .alignFullWidth()
                    }

                    VStack(spacing: 16) {
                        ForEach(WorkoutGoalData.allCases, id: \.self) { workoutGoal in
                            NavigationLink(destination: EditTrainingRunGoalView(goal, workoutGoal: workoutGoal)) {
                                AddTrainingGoalTypeCard(
                                    icon: workoutGoal.getWorkoutIcon(),
                                    title: workoutGoal.getWorkoutName(),
                                    description: workoutGoal.getWorkoutDescription()
                                )
                            }
//                            VStack {
//                                EditTrainingRunWorkout(goal: Binding(
//                                    get: { workoutGoal },
//                                    set: { workoutGoal = $0 }
//                                ))
//                                    .onAppear {
//                                        workoutGoal = goal
//                                    }
//                                Button("Save") {
//                                    print("Goal: \(workoutGoal) - \(selectedDate)")
//                                    activeUser.training.updateTrainingGoal(
//                                        selectedDate,
//                                        TrainingRunGoalData(
//                                            date: selectedDate,
//                                            workout: workoutGoal
//                                        )
//                                    )
//                                    activeUser.training.updateTrainingDayType(
//                                        selectedDate,
//                                        workoutGoal
//                                    )
//                                    print("Save")
//                                    dismiss()
//                                }
//                                    .buttonStyle(EnduraNewButtonStyle())
//                            }
//                            ) {
//                                AddTrainingGoalTypeCard(
//                                    icon: goal.getWorkoutIcon(),
//                                    title: goal.getWorkoutName(),
//                                    description: goal.getWorkoutDescription()
//                                )
//                            }
                        }
                    }
                }
                .enduraPadding()
            }
        }
    }
}

struct AddTrainingGoalTypeCard: View {
    private let icon: String
    private let title: String
    private let description: String

    public init(icon: String, title: String, description: String) {
        self.title = title
        self.description = description
        self.icon = icon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontColor(.primary)
                Image(systemName: icon)
                    .font(.title)
                    .fontWeight(.bold)
                    .alignFullWidth(.trailing)
            }

            Text(description)
                .font(.system(size: 16))
                .multilineTextAlignment(.leading)
                .fontColor(.secondary)
        }
        .alignFullWidth()
        .padding(26)
        .enduraDefaultBox()
    }
}
