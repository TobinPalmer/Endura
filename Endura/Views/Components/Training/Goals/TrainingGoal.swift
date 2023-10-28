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

private struct TrainingGoalSingleGoal: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    fileprivate let goal: TrainingRunGoalData

    init(_ goal: TrainingRunGoalData) {
        self.goal = goal
    }

    public var body: some View {
        VStack(alignment: .leading) {
            // Warmup
            if let preRoutine = goal.preRoutine {
                HStack {
                    Image(systemName: "figure.flexibility")
                        .font(.title)
                        .foregroundColor(preRoutine.difficulty.getColor())
                        .fontWeight(.bold)
                        .padding(.trailing, 5)

                    Text(String(describing: preRoutine.type.rawValue))
                        //            .foregroundColor(preRoutine.difficulty.getColor())
                        .alignFullWidth()

                    ColoredBadge(preRoutine.difficulty)
                }
                .background(Color(UIColor.systemBackground))
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

                TrainingGoalHorizontalDivider()
            }

            // Main goal section
            HStack {
                // Icon
                Image(systemName: "figure.run")
                    .font(.title)
                    .foregroundColor(goal.type.getColor())
                    .fontWeight(.bold)
                    .padding(.trailing, 5)

                // Title + Desc
                VStack {
                    HStack {
                        Text(String(describing: goal.getTitle()))
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                            .alignFullWidth()
                    }

                    // Stats
                    VStack {
                        HStack {
                            Text("\(FormattingUtils.formatMiles(goal.getDistance())) mi")
                                .font(.system(size: 12))
                                .fontColor(.primary)
                                .alignFullWidth()
                        }
                        HStack {
                            Text(FormattingUtils.secondsToFormattedTime(goal.getTime()))
                                .font(.system(size: 12))
                                .fontColor(.primary)
                                .alignFullWidth()
                        }
                    }

                    ColoredBadge(goal.type)

                    Text(String(describing: goal.description))
                        .font(.body)
                        .fontColor(.secondary)
                        .alignFullWidth()
                }
            }
            .background(Color(UIColor.systemBackground))
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

            // Postrun
            if let postRoutine = goal.postRoutine {
                TrainingGoalHorizontalDivider()

                HStack {
                    Image(systemName: "figure.core.training")
                        .font(.title)
                        .foregroundColor(postRoutine.difficulty.getColor())
                        .fontWeight(.bold)
                        .padding(.trailing, 5)

                    Text(String(describing: postRoutine.type.rawValue))
                        //            .foregroundColor(postRoutine.difficulty.getColor())
                        .alignFullWidth()

                    ColoredBadge(postRoutine.difficulty)
                }
                .background(Color(UIColor.systemBackground))
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
