import Foundation
import SwiftUI

private final class EditRunningTrainingGoalViewModel: ObservableObject {}

struct EditRunningTrainingGoalView: View {
    @StateObject private var viewModel = EditRunningTrainingGoalViewModel()
    @State var goal: RunningTrainingGoalData

    var body: some View {
        VStack {
            Text("Edit Training Goal")
                .font(.title)
                .padding()
            Text("Distance: \(goal.distance.removeTrailingZeros()) Miles")
            Stepper("Distance", value: $goal.distance, in: 0 ... 100, step: 0.1)
            Text("Time: \(goal.time.removeTrailingZeros()) Minutes")
            Stepper("Time", value: $goal.time, in: 0 ... 100, step: 0.1)
            Text("Pace: \(goal.pace.removeTrailingZeros()) Minutes/Mile")
            Stepper("Pace", value: $goal.pace, in: 0 ... 100, step: 0.1)
            Spacer()
        }
    }
}
