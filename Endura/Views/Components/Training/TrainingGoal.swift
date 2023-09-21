import Foundation
import SwiftUI

struct TrainingGoal: View {
    private let goal: TrainingGoalData

    public init(_ goal: TrainingGoalData) {
        self.goal = goal
    }

    var body: some View {
        HStack {
            ZStack {
                switch goal {
                case .warmup:
                    Image(systemName: "figure.cooldown")
                case .run:
                    Image(systemName: "figure.run")
                case .postRun:
                    Image(systemName: "figure.strengthtraining.functional")
                }
            }
            VStack(alignment: .leading) {
                switch goal {
                case .run:
                    Text("Run")
                case .postRun:
                    Text("Post Run")
                case .warmup:
                    Text("Warm Up")
                }

                switch goal {
                case let .run(dificulty, distance, time, pace):
                    VStack {
                        Text("\(distance.removeTrailingZeros()) Miles")
                        Text("\(time.removeTrailingZeros()) Minutes")
                        Text("\(pace.removeTrailingZeros()) Minutes/Mile")
                        Text("\(dificulty.rawValue)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                case let .postRun(_, time, _):
                    HStack {
                        Text("\(time.removeTrailingZeros()) Minutes")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                case let .warmup(time, _):
                    HStack {
                        Text("\(time.removeTrailingZeros()) Minutes")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(26)
        .EnduraDefaultBox()
    }
}
