import Foundation
import SwiftUI

private struct TrainingGoalSingleGoal: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    fileprivate let goal: TrainingRunGoalData

    init(_ goal: TrainingRunGoalData) {
        self.goal = goal
    }

    public var body: some View {
        VStack {
            HStack {
                Text(String(describing: goal.getTitle()))
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontColor(.primary)
                    .alignFullWidth()

                Spacer()

                if goal.progress.allCompleted() {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }

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

                        if goal.progress.workoutCompleted {
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
            if let postRoutine = goal.postRoutine {
                TrainingRoutineGoal(postRoutine)
            }
        }
    }
}

private struct TrainingGoalHorizontalDivider: View {
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundColor(Color(UIColor.separator))
            }
        }
    }
}

struct TrainingGoal2: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    private let goal: [TrainingRunGoalData]

    public init(_ goal: [TrainingRunGoalData]) {
        self.goal = goal
    }

    var body: some View {
        VStack {
            ForEach(goal, id: \.self) { goal in
                TrainingGoalSingleGoal(goal)
            }
        }
        .alignFullWidth()
        .padding(26)
        .enduraDefaultBox()
//    VStack {
//      if let preRoutine = goal.preRoutine {
//        TrainingRoutineGoal(preRoutine)
//      }
//      NavigationLink(destination: TrainingGoalDetails(goal)) {
//        VStack(alignment: .leading) {
//          HStack {
//            Image(systemName: "figure.run")
//              .font(.title)
//              .foregroundColor(goal.type.getColor())
//              .fontWeight(.bold)
//
//            Text(goal.getTitle())
//              .font(.title3)
//              .fontColor(.primary)
//              .fontWeight(.bold)
//
//            Spacer()
//
//            if goal.progress.completed {
//              Image(systemName: "checkmark")
//                .font(.title3)
//                .foregroundColor(.green)
//            }
//          }
//
//          ColoredBadge(goal.type)
//
//          Text(goal.description)
//            .multilineTextAlignment(.leading)
//            .font(.body)
//            .fontColor(.secondary)
//
//          TrainingGoalProgress(goal)
//        }
//          .alignFullWidth()
//          .padding(26)
//          .enduraDefaultBox()
//      }
//        .contextMenu {
//          Button(action: {
//            var goal = goal
//            goal.progress.completed.toggle()
//            activeUser.training.updateTrainingGoal(goal.date, goal)
//          }) {
//            if goal.progress.completed {
//              Label("Completed", systemImage: "checkmark")
//            } else {
//              Text("Mark as Complete")
//            }
//          }
//          Divider()
//          Button(role: .destructive, action: {
//            activeUser.training.removeTrainingGoal(goal.date, goal)
//          }) {
//            Label("Remove", systemImage: "trash")
//          }
//        }
//      if let postRoutine = goal.postRoutine {
//        TrainingRoutineGoal(postRoutine)
//      }
//    }
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
                    VStack(alignment: .leading) {
                        HStack {
                            if goal.progress.workoutCompleted {
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
