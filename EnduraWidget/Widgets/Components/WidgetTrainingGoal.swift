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

            Grid(verticalSpacing: 2) {
                GridRow {
                    Image(systemName: "ruler")
                    Spacer()
                    Image(systemName: "timer")
                }
                .font(.system(size: 15))
                .fontWeight(.bold)
                GridRow {
                    Text("\(FormattingUtils.formatMiles(goal.getDistance())) mi")
                    Spacer()
                    Text("\(FormattingUtils.secondsToFormattedTime(goal.getTime()))")
                }
                .font(.system(size: 15))
            }
            .frame(height: 40, alignment: .bottom)
            .foregroundColor(.white)
            .padding(.top, 6)
            .padding(.horizontal, 10)
        }
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
