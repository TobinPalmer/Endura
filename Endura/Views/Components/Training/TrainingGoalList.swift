import Foundation
import SwiftUI

struct TrainingGoalList: View {
    var body: some View {
        VStack {
            TrainingGoal(.warmup, goal: WarmupTrainingGoal(type: .warmup, count: 1, time: 10))
            TrainingGoal(.running, goal: RunningTrainingGoal(
                difficulty: .hard,
                distance: 5.03,
                pace: 6,
                runType: .normal,
                time: 30,
                type: .running
            ))
            TrainingGoal(.postRun, goal: PostRunTrainingGoal(type: .postRun, count: 1, time: 10))
        }
    }
}
