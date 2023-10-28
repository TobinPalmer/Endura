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
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .padding(.bottom, 1)

            Text(String(describing: goal.description))
                .font(.body)
                .fontColor(.secondary)
                .alignFullWidth()

            ActivityPostStats(distance: goal.getDistance(), duration: goal.getTime())

            Divider()

            VStack {
                if let preRoutine = goal.preRoutine {
                    NavigationLink(destination: RoutineStartView(preRoutine)) {
                        goalListItem(text: "Warmup", icon: "figure.cooldown")
                    }
                }
                goalListItem(text: "Run", icon: "figure.run")
                if let postRoutine = goal.postRoutine {
                    NavigationLink(destination: RoutineStartView(postRoutine)) {
                        goalListItem(text: "Post run", icon: "figure.strengthtraining.functional")
                    }
                }
            }
        }
        .padding(20)
        .enduraDefaultBox()
        .contextMenu {
            Button(action: {
                var goal = goal
                goal.progress.workoutCompleted.toggle()
                activeUser.training.updateTrainingGoal(goal.date, goal)
            }) {
                if goal.progress.workoutCompleted {
                    Label("Completed", systemImage: "checkmark")
                } else {
                    Text("Mark as Complete")
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

    private func goalListItem(text: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)

            Text(text)
                .font(.body)
                .fontColor(.secondary)

            Spacer()

            Button("Start") {}
                .font(.system(size: 15))
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(50)
        }
        .frame(height: 40)
    }
}
