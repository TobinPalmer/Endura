import Foundation
import SwiftUI

struct TrainingGoalProgress: View {
    private let goal: TrainingRunGoalData

    public init(_ goal: TrainingRunGoalData) {
        self.goal = goal
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity)
                .frame(height: 10)
                .background(Color("TextMuted"))
                .cornerRadius(50)

            HStack {
                ForEach(
                    [goal.preRoutine?.progress.completed, goal.progress.completed,
                     goal.postRoutine?.progress.completed],
                    id: \.self
                ) { completed in
                    if completed == true {
                        Circle()
                            .foregroundColor(.accentColor)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 5)
                    } else {
                        Circle()
                            .foregroundColor(.clear)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 5)
                    }
                }
            }
        }
    }
}
