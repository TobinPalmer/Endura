import Foundation
import SwiftUI

struct GenerateTrainingGoalsView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel

    @State private var output = ""

    var body: some View {
        VStack {
            Text("Generate Training Goals!")

            Text(output)

            Button {
                print("Generating training goals")
                if let endGoal = activeUser.training.endTrainingGoal {
                    if let encodedEndGoal = TrainingGenerationDataUtils
                        .encodeTrainingPlan(activeUser.training.monthlyTrainingData)
                    {
                        print("\n\n\n\(encodedEndGoal)\n\n\n")
//                        let decodedGoal = TrainingGenerationDataUtils.decodeTrainingPlan(encodedEndGoal)
//                        print("\n\n\n\(decodedGoal)\n\n\n")
//                        Task {
//                            if let output = await TrainingGenerationUtils
//                                .generateWithTrainingAI(
//                                    "Is this a good goal? Explain why or why not. (\(encodedEndGoal))"
//                                )
//                            {
//                                print("\(output)")
//                                self.output = output
//                            }
//                        }
                    }
                }
            } label: {
                Text("Generate")
            }
        }
    }
}
