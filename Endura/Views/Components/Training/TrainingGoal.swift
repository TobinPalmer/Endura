import Foundation
import SwiftUI

struct TrainingGoal: View {
    private let type: TrainingGoalType
    private let goal: TrainingGoalBase

    public init<T>(_ type: TrainingGoalType, goal: T) where T: TrainingGoalBase {
        self.type = type
        self.goal = goal
    }

    var body: some View {
        VStack {
            switch type {
            case .running:
                if let goal = goal as? RunningTrainingGoal {
                    TrainingGoalListing(type, goal: goal, icon: Image(systemName: "figure.run"))
                }

            case .postRun:
                if let goal = goal as? PostRunTrainingGoal {
                    TrainingGoalListing(type, goal: goal, icon: Image(systemName: "figure.cooldown"))
                }

            case .warmup:
                TrainingGoalListing(type, goal: goal, icon: Image(systemName: "figure.walk"))
            }
        }
    }
}

private struct TrainingGoalListing: View {
    private let type: TrainingGoalType
    private let goal: TrainingGoalBase
    private let icon: Image

    fileprivate init(_ type: TrainingGoalType, goal: TrainingGoalBase, icon: Image) {
        self.type = type
        self.goal = goal
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: 0) {
            HStack {
                icon
                    .font(.title2)
                VStack {
                    Text("Warm Up")
                    Text("x\(goal.time.removeTrailingZeros())")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if type == .running {
                if let goal = goal as? RunningTrainingGoal {
                    HStack {
                        Text("\(goal.distance.removeTrailingZeros()) Miles")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                HStack {
                    Text("\(goal.time.removeTrailingZeros()) Minutes")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .shadow(radius: 2)
        .padding()
        .cornerRadius(8)
        .border(.red)
    }
}
