import Foundation
import SwiftUI

struct WidgetTrainingGoal: View {
    private let goal: TrainingRunGoalDataDocument

    public init(_ goal: TrainingRunGoalDataDocument) {
        self.goal = goal
    }

    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text("\(goal.type.rawValue) Day")
                    .font(.title3)
                    .fontWeight(.bold)
                    //                    .foregroundColor(goal.type.getColor())
                    .foregroundColor(.white)
                    .alignFullWidth()

                Spacer()

                if goal.progress?.allCompleted() ?? false {
                    Image(systemName: "checkmark.circle")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }

            Text(String(describing: goal.description))
                .font(.system(size: 14))
                .foregroundColor(.white)
                .alignFullWidth()

            HStack {
                Spacer()
                VStack {
                    Text("Distance")
                        .font(.system(size: 12))
                        .fontColor(.secondary)
                    Text("\(FormattingUtils.formatMiles(goal.getDistance()))")
                        .font(.system(size: 14))
                        .fontColor(.primary)
                }
                Spacer()
                VStack {
                    Text("Time")
                        .font(.system(size: 12))
                        .fontColor(.secondary)
                    Text("\(FormattingUtils.secondsToFormattedTime(goal.getTime()))")
                        .font(.system(size: 14))
                        .fontColor(.primary)
                }
                Spacer()
                VStack {
                    Text("Pace")
                        .font(.system(size: 12))
                        .fontColor(.secondary)
                    let pace = goal.getDistance() * 1609.34 / goal.getTime()
                    Text("\(ConversionUtils.convertMpsToMpm(pace))")
                        .font(.system(size: 14))
                        .fontColor(.primary)
                }
                Spacer()
            }
        }
    }
}
