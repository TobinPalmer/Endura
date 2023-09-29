import Foundation
import SwiftUI

struct TrainingGoal: View {
    private let goal: TrainingGoalData

    public init(_ goal: TrainingGoalData) {
        self.goal = goal
    }

    var body: some View {
        NavigationLink(destination: TrainingGoalDetails(goal)) {
            HStack {
                Image(systemName: goal.getIcon())
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(goal.getBackgroundColor())
                            .frame(width: 50, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(goal.getColor(), lineWidth: 2)
                            )
                    )
                    .frame(width: 50, height: 50)
                HStack {
                    VStack(alignment: .leading) {
                        Text(goal.getTitle())
                        switch goal {
                        case let .run(data):
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(data.distance.removeTrailingZeros()) Miles")
                                }
                            }
                        case let .routine(data):
                            VStack(alignment: .leading) {
                                Text("\(data.count) Exercises")
                            }
                        }
                    }
                    Spacer()
                    switch goal {
                    case let .routine(data):
                        timeAndProgressView(time: data.time, progress: data.progress)
                    case let .run(data):
                        timeAndProgressView(time: data.time, progress: data.progress)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(26)
            .EnduraDefaultBox()
        }
    }

    func timeAndProgressView(time: Double, progress: TrainingGoalProgressData) -> some View {
        HStack {
            if progress.completed {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            } else {
                Text("\(time.removeTrailingZeros()) Minutes")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 50).foregroundColor(goal.getColor()))
            }
        }
    }
}
