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
                Image(systemName: goal.getIcon())
            }
            VStack(alignment: .leading) {
                Text(goal.getTitle())

                switch goal {
                case let .run(type, distance, time, pace):
                    VStack(alignment: .leading) {
                        Text("\(distance.removeTrailingZeros()) Miles")
                        Text("\(time.removeTrailingZeros()) Minutes")
                        Text("\(pace.removeTrailingZeros()) Minutes/Mile")
                        Text("\(type.rawValue)")
                    }
                case let .routine(_, _, time, _):
                    VStack(alignment: .leading) {
                        Text("\(time.removeTrailingZeros()) Minutes")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(26)
        .EnduraDefaultBox()
    }
}
