import Foundation
import SwiftUI

struct TrainingGoal: View {
    private let goal: TrainingGoalData

    public init(_ goal: TrainingGoalData) {
        self.goal = goal
    }

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                HStack {
                    switch goal {
                    case .warmup:
                        Image(systemName: "figure.walk")
                    case .run:
                        Image(systemName: "figure.run")
                    case .postRun:
                        Image(systemName: "figure.cooldown")
                    }
                }
                VStack {
                    Text("Warm Up")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            switch goal {
            case let .run(type, distance, time, pace):
                VStack {
                    Text("\(distance.removeTrailingZeros()) Miles")
                    Text("\(time.removeTrailingZeros()) Minutes")
                    Text("\(pace.removeTrailingZeros()) Minutes/Mile")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            case let .postRun(type, time, count):
                HStack {
                    Text("\(time.removeTrailingZeros()) Minutes")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            case let .warmup(time, count):
                HStack {
                    Text("\(time.removeTrailingZeros()) Minutes")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding()
        .background(Color.white)
        .compositingGroup()
        .shadow(color: Color.black, radius: 2)
    }
}
