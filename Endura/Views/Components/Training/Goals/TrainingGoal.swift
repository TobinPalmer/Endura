import Foundation
import SwiftUI

public struct TrainingGoal: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    fileprivate let goal: TrainingRunGoalData

    init(_ goal: TrainingRunGoalData) {
        self.goal = goal
    }

    public var body: some View {
        VStack {
            HStack {
                Text("\(goal.type.rawValue) Day")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(goal.type.getColor())
                    .alignFullWidth()

                Spacer()

                if goal.progress.allCompleted() {
                    Image(systemName: "checkmark.circle")
                        .font(.title)
                        .foregroundColor(.accentColor)
                } else {
                    NavigationLink(destination: EditTrainingRunGoalView(goal)) {
                        Image(systemName: "pencil.circle")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(.bottom, 1)

            Text(String(describing: goal.description))
                .font(.body)
                .fontColor(.secondary)
                .alignFullWidth()

            switch goal.workout {
            case let .custom(workout):
                CustomWorkoutStats(workout)
            default:
                ActivityPostStats(distance: goal.getDistance(), duration: goal.getTime())
            }

            VStack {
                if let preRoutine = goal.preRoutine {
                    NavigationLink(destination: RoutineStartView(preRoutine, date: goal.date)) {
                        goalListItem(text: "Warmup", icon: "figure.cooldown", done: goal.progress.preRoutineCompleted)
                    }
                }
                NavigationLink(destination: NewActivityView()) {
                    goalListItem(
                        text: goal.workout
                            .isCustomWorkout() ? "Workout" :
                            "\(FormattingUtils.formatMiles(goal.getDistance())) Mile Run",
                        icon: "figure.run",
                        done: goal.progress.workoutCompleted,
                        buttonText: "Upload"
                    )
                }
                if let postRoutine = goal.postRoutine {
                    NavigationLink(destination: RoutineStartView(postRoutine, date: goal.date)) {
                        goalListItem(
                            text: "Post run",
                            icon: "figure.strengthtraining.functional",
                            done: goal.progress.postRoutineCompleted
                        )
                    }
                }
            }
        }
        .padding(20)
        .enduraDefaultBox()
        .contextMenu {
            if goal.preRoutine != nil {
                Button(action: {
                    var goal = goal
                    goal.progress.preRoutineCompleted.toggle()
                    activeUser.training.updateTrainingGoal(goal.date, goal)
                }) {
                    if goal.progress.preRoutineCompleted {
                        Label("Warmup Completed", systemImage: "checkmark")
                    } else {
                        Text("Warmup Completed")
                    }
                }
            }
            Button(action: {
                var goal = goal
                goal.progress.workoutCompleted.toggle()
                activeUser.training.updateTrainingGoal(goal.date, goal)
            }) {
                if goal.progress.workoutCompleted {
                    Label("Run Completed", systemImage: "checkmark")
                } else {
                    Text("Run Completed")
                }
            }
            if goal.postRoutine != nil {
                Button(action: {
                    var goal = goal
                    goal.progress.postRoutineCompleted.toggle()
                    activeUser.training.updateTrainingGoal(goal.date, goal)
                }) {
                    if goal.progress.postRoutineCompleted {
                        Label("Post Run Completed", systemImage: "checkmark")
                    } else {
                        Text("Post Run Completed")
                    }
                }
            }
            Divider()
            Button(role: .destructive, action: {
                activeUser.training.removeTrainingGoal(goal.date, goal)
            }) {
                Label("Remove", systemImage: "trash")
            }
        }
    }

    private func goalListItem(text: String, icon: String, done: Bool = false,
                              buttonText: String = "Start") -> some View
    {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)

            Text(text)
                .font(.body)
                .fontColor(.secondary)

            Spacer()

            if done {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            } else {
                Button(buttonText) {}
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(50)
            }
        }
        .frame(height: 40)
    }
}
