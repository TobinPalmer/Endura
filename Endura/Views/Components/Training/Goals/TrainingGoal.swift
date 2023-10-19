import Foundation
import SwiftUI

struct TrainingGoal: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    private let goal: TrainingRunGoalData

    public init(_ goal: TrainingRunGoalData) {
        self.goal = goal
    }

    var body: some View {
        VStack {
            if let preRoutine = goal.preRoutine {
                TrainingRoutineGoal(preRoutine)
            }
            NavigationLink(destination: TrainingGoalDetails(goal)) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "figure.run")
                            .font(.title)
                            .foregroundColor(goal.type.getColor())
                            .fontWeight(.bold)

                        Text(goal.getTitle())
                            .font(.title3)
                            .fontColor(.primary)
                            .fontWeight(.bold)

                        Spacer()

                        if goal.progress.completed {
                            Image(systemName: "checkmark")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }

                    ColoredBadge(goal.type)

                    Text(goal.description)
                        .multilineTextAlignment(.leading)
                        .font(.body)
                        .fontColor(.secondary)

                    TrainingGoalProgress(goal)
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
            if let postRoutine = goal.postRoutine {
                TrainingRoutineGoal(postRoutine)
            }
        }
    }
}

struct TrainingRoutineGoal: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    private let goal: TrainingRoutineGoalData

    public init(_ goal: TrainingRoutineGoalData) {
        self.goal = goal
    }

    var body: some View {
        VStack {
            NavigationLink(destination: RoutineStartView(goal)) {
                HStack(alignment: .top, spacing: 10) {
//                Image(systemName: "figure.walk")
//                    .font(.title)
//                    .foregroundColor(goal.type.getColor())
//                    .fontWeight(.bold)

                    VStack(alignment: .leading) {
                        HStack {
                            if goal.progress.completed {
                                Image(systemName: "checkmark")
                                    .font(.title3)
                                    .foregroundColor(.green)
                            }

                            Text(goal.type.rawValue)
                                .font(.title3)
                                .fontColor(.primary)
                                .fontWeight(.bold)

                            Spacer()
                        }

                        Text(goal.difficulty.rawValue)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .fontColor(.secondary)
                    }
                }
            }
            .alignFullWidth()
            .padding(26)
            .enduraDefaultBox()
        }
    }
}
