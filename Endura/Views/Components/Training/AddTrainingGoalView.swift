import Foundation
import SwiftUI

struct AddTrainingGoalView: View {
    var body: some View {
        VStack {
            Text("Add Training Goal")
                .font(.title)
                .padding()
            NavigationLink(destination: Text("Coming Soon")) {
                Text("Add Routine Goal")
            }
            NavigationLink(destination: EditRunningTrainingGoalView(goal: RunningTrainingGoalData(
                type: .normal,
                workout: .distance(distance: 5)
            ))) {
                Text("Add Running Goal")
            }
            Spacer()
        }
    }
}
