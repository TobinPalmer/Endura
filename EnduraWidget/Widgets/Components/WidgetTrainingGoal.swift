import Foundation
import SwiftUI

struct WidgetTrainingGoal: View {
    private let goal: TrainingRunGoalDataDocument
    private let big: Bool

    public init(_ goal: TrainingRunGoalDataDocument, big: Bool = false) {
        self.goal = goal
        self.big = big
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
                    if big {
                        Spacer()
                        Image(systemName: "speedometer")
                    }
                }
                .font(.system(size: 15))
                .fontWeight(.bold)
                GridRow {
                    Text("\(FormattingUtils.formatMiles(goal.getDistance())) mi")
                    Spacer()
                    Text("\(FormattingUtils.secondsToFormattedTime(goal.getTime()))")
                    if big {
                        Spacer()
                        Text("\(ConversionUtils.convertMpsToMpm(goal.getDistance() * 1609.34 / goal.getTime())) /mi")
                    }
                }
                .font(.system(size: 15))
            }
            .frame(height: 40, alignment: .bottom)
            .foregroundColor(.white)
            .padding(.top, 6)
            .padding(.leading, 10)
            .padding(.trailing, big ? 0 : 10)
        }
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
