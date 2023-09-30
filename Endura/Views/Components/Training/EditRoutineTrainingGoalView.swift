import Foundation
import SwiftUI

private final class EditRoutineTrainingGoalViewModel: ObservableObject {}

struct EditRoutineTrainingGoalView: View {
    @StateObject private var viewModel = EditRoutineTrainingGoalViewModel()
    @State var goal: RoutineTrainingGoalData

    var body: some View {
        VStack {
            Text("Coming soon!")
        }
    }
}
