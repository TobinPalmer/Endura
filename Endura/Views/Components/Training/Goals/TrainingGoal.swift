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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(26)
            .enduraDefaultBox()
        }
    }
}
