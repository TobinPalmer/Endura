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
            Text("Time: \(goal.time.removeTrailingZeros()) Minutes")
            Text("Pace: \(goal.pace.removeTrailingZeros()) Minutes/Mile")
            Spacer()
        }
    }
}
