import Foundation
import SwiftUI

struct TrainingGoal: View {
    private let goal: TrainingRunGoalData

    public init(_ goal: TrainingRunGoalData) {
        self.goal = goal
    }

    var body: some View {
        NavigationLink(destination: TrainingGoalDetails(goal)) {
            HStack(alignment: .top, spacing: 10) {
//                Image(systemName: goal.getIcon())
//                .font(.title)
//                .foregroundColor(goal.getColor())
//                .fontWeight(.bold)

                VStack(alignment: .leading) {
                    Text(goal.getTitle())
                        .font(.title3)
                        .fontColor(.primary)
                        .fontWeight(.bold)

                    Text("This is the description of the goal.")
                        .multilineTextAlignment(.leading)
                        .font(.body)
                        .fontColor(.secondary)
                }
            }
            .alignFullWidth()
            .padding(26)
            .enduraDefaultBox()

            //                        switch goal {
            //                        case let .run(data):
            //                            VStack(alignment: .leading) {
            //                                HStack {
            //                                    Text("\(data.getDistance().removeTrailingZeros()) Miles")
            //                                }
            //                            }
            //                        case let .routine(data):
            //                            VStack(alignment: .leading) {
            //                                Text("\(data.count) Exercises")
            //                            }
            //                        }
            //                    }
            //                    Spacer()
            //                    switch goal {
            //                    case let .routine(data):
            //                        HStack {
            //                            if data.progress.completed {
            //                                Image(systemName: "checkmark")
            //                                    .foregroundColor(.green)
            //                            } else {
            //                                Text("\(FormattingUtils.secondsToFormattedTime(data.time))
            //                                Minutes")
            //                                    .padding()
            //                                    .background(RoundedRectangle(cornerRadius: 50).foregroundColor(goal.getColor()))
            //                            }
            //                        }
            //                    case let .run(data):
            //                        HStack {
            //                            if data.progress.completed {
            //                                Image(systemName: "checkmark")
            //                                    .foregroundColor(.green)
            //                            } else {
            //                                VStack {
            //                                    switch data.workout {
            //                                    case let .distance(distance):
            //                                        Text("\(FormattingUtils.formatMiles(distance)) Miles")
            //                                    case let .time(time):
            //                                        Text("\(FormattingUtils.secondsToFormattedTime(time))
            //                                        Minutes")
            //                                    default: EmptyView()
            //                                    }
            //                                }
            //                                .padding()
            //                                .background(RoundedRectangle(cornerRadius: 50).foregroundColor(goal.getColor()))
            //                            }
            //                        }
            //                    }
        }
    }
}
