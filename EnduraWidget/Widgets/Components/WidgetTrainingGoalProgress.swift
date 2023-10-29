import Foundation
import SwiftUI

struct WidgetTrainingGoalProgress: View {
    private let goal: TrainingRunGoalDataDocument

    public init(_ goal: TrainingRunGoalDataDocument) {
        self.goal = goal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let preRoutine = goal.preRoutine {
                HStack {
                    Label("Warmup", systemImage: "figure.cooldown")
                    if goal.progress?.preRoutineCompleted ?? false {
                        Image(systemName: "checkmark")
                    }
                }
            }
            HStack {
                Label("\(FormattingUtils.formatMiles(goal.getDistance())) Mile Run", systemImage: "figure.run")
                if goal.progress?.workoutCompleted ?? false {
                    Image(systemName: "checkmark")
                }
            }
            if let postRoutine = goal.postRoutine {
                HStack {
                    Label("Post run", systemImage: "figure.strengthtraining.functional")
                    if goal.progress?.postRoutineCompleted ?? false {
                        Image(systemName: "checkmark")
                    }
                }
            }
//            Button("Start \(goal.progress?.getNext() ?? "")") {
//                print("Start \(goal.progress?.getNext() ?? "")")
//            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .foregroundColor(.white)
        .font(.system(size: 15))
        .fontWeight(.bold)
//        ZStack {
//            Circle()
//                .stroke(Color.accentColor, lineWidth: 16)
//                .frame(width: 150, height: 150)
//
//            VStack {
//                let text = goal.progress?.allCompleted() ?? false ? "Done" : "Next Up: "
//                Text("\(text)")
//                    .font(.system(size: 20, weight: .bold, design: .rounded))
//                    .foregroundColor(.accentColor)
//                if let next = goal.progress?.getNext() {
//                    Text("\(next)")
//                        .font(.system(size: 50, weight: .bold, design: .rounded))
//                        .foregroundColor(.accentColor)
//                }
//            }
//        }
    }
}
