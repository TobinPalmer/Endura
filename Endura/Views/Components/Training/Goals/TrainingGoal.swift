import Foundation
import SwiftUI

struct TrainingGoal: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    private let goal: TrainingRunGoalData

    public init(_ goal: TrainingRunGoalData) {
        self.goal = goal
    }

    var body: some View {
        NavigationLink(destination: TrainingGoalDetails(goal)) {
            HStack(alignment: .top, spacing: 10) {
//                Image(systemName: goal.getIcon())
//                .font(.title)
//                .foregroundColor(goal.getColor())
//                .fontWeight(.bold)

                VStack(alignment: .leading) {
                    Text(goal.getTitle())
                        .font(.title3)
                        .fontColor(.primary)
                        .fontWeight(.bold)

                    Text("This is the description of the goal.")
                        .multilineTextAlignment(.leading)
                        .font(.body)
                        .fontColor(.secondary)
                }
            }
            .alignFullWidth()
            .padding(26)
            .enduraDefaultBox()
        }
        .contextMenu {
            Button(action: {
                var goal = goal
                goal.progress.completed.toggle()
                activeUser.training.updateTrainingGoal(goal.date, goal)
            }) {
                if goal.progress.completed {
                    Label("Completed", systemImage: "checkmark")
                } else {
                    Label("Mark as Complete", systemImage: "")
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
}
