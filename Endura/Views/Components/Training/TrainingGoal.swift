import Foundation
import SwiftUI

struct TrainingGoal: View {
    private let goal: TrainingGoalData

    public init(_ goal: TrainingGoalData) {
        self.goal = goal
    }

    var body: some View {
        HStack {
            HStack(spacing: 0) {
                ZStack {
                    switch goal {
                    case .warmup:
                        Image("figure_running")
                    case .run:
//            Image(systemName: "figure.run")
                        Text("RUN")
                    case .postRun:
//            Image(systemName: "figure.cooldown")
                        Text("COOLDOWN")
                    }
                }
                VStack {
                    Text("Warm Up")
                        .frame(maxWidth: .infinity, alignment: .leading)

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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(26)
        .EnduraDefaultBox()
    }
}
