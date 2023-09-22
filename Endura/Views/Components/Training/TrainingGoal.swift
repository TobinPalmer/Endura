import Foundation
import SwiftUI

struct TrainingGoal: View {
    private let goal: TrainingGoalData

    public init(_ goal: TrainingGoalData) {
        self.goal = goal
    }

    var body: some View {
        HStack {
            Image(systemName: goal.getIcon())
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .foregroundColor(goal.getColor())
                        .frame(width: 50, height: 50)
                )
                .frame(width: 50, height: 50)
            HStack {
                VStack(alignment: .leading) {
                    Text(goal.getTitle())
                    switch goal {
                    case let .run(_, distance, _, _):
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(distance.removeTrailingZeros()) Miles")
                            }
                        }
                    case let .routine(_, _, time, _):
                        VStack(alignment: .leading) {
                            Text("\(time.removeTrailingZeros()) Minutes")
                        }
                    }
                }
                Spacer()
                switch goal {
                case let .routine(_, _, time, _),
                     let .run(_, _, time, _):
                    Text("\(time.removeTrailingZeros()) Minutes")
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 50).foregroundColor(.blue))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(26)
        .EnduraDefaultBox()
    }
}
