import Foundation
import SwiftUI

struct GenerateTrainingGoalsView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State var startDate: Date = .init()
    @State var endDate: Date = .init()

    var body: some View {
        VStack {
            Text("Generate Training Goals!")

            Button {
                print("Generating training goals")
                if let endGoal = activeUser.training.endTrainingGoal {
                    print(TrainingGenerationDataUtils.encodeEndTrainingGoal(endGoal))
                }
            } label: {
                Text("Generate")
            }
        }
    }
}
