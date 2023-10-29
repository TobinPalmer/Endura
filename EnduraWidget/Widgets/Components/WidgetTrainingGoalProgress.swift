import Foundation
import SwiftUI

struct WidgetTrainingGoalProgress: View {
    private let goal: TrainingRunGoalDataDocument

    public init(_ goal: TrainingRunGoalDataDocument) {
        self.goal = goal
    }

    var body: some View {
        VStack {
            if let preRoutine = goal.preRoutine {
                Label("Warmup", systemImage: "figure.cooldown")
            }
            Label("\(FormattingUtils.formatMiles(goal.getDistance())) Mile Run", systemImage: "figure.run")
            if let postRoutine = goal.postRoutine {
                Label("Post run", systemImage: "figure.strengthtraining.functional")
            }
        }
    }
}
