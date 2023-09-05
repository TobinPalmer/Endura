import Foundation
import SwiftUI

struct TrainingGoalList: View {
    var body: some View {
        VStack {
            TrainingGoal(TrainingGoalData.warmup(time: 10, count: 1))
            TrainingGoal(TrainingGoalData.run(
                distance: 5.03,
                pace: 6,
                time: 30,
                difficulty: .hard,
                runType: .long
            ))
            TrainingGoal(TrainingGoalData.postRun(time: 10, count: 1))
        }
    }
}
