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
                let athleteInfo = TrainingGenerationDataUtils.createAthleteInfo(activeUser.data)
                let encodedEndGoal = TrainingGenerationDataUtils.encodeEndTrainingGoal(
                    activeUser.training.endTrainingGoal!
                )
                print("Encoded end goal: \(encodedEndGoal ?? "nil")")

                Task {
                    if let outputs = await TrainingGenerationUtils.generateMultiOutputWithTrainingAI(inputs: [
                        "a = 1 + 2",
                        "b = 3 + a",
                        "a = b * 2",
                        "b = a / 4",
                    ],
                    context: "Replace the right side of the equation with only the answer as an int, no explanation.") {
                        for output in outputs {
                            print("\nOutput: \(output)")
                            self.output.append("\(output)\n")
                        }
                    }
                }

//                if let endGoal = activeUser.training.endTrainingGoal {
//                    if let encodedEndGoal = TrainingGenerationDataUtils
//                        .encodeTrainingPlan(activeUser.training.monthlyTrainingData)
//                    {
//                        let printText = "\n\n\n\(encodedEndGoal)\n\n\n".replacing(
//                            ",",
//                            with: ",\n"
//                        ).replacing(
//                            "{",
//                            with: "{\n"
//                        ).replacing(
//                            "}",
//                            with: "\n}"
//                        )
//                        print("\(printText)")
                ////                        let decodedGoal =
                // TrainingGenerationDataUtils.decodeTrainingPlan(encodedEndGoal)
                ////                        print("\n\n\n\(decodedGoal)\n\n\n")
                ////                        Task {
                ////                            if let output = await TrainingGenerationUtils
                ////                                .generateWithTrainingAI(
                ////                                    "Is this a good goal? Explain why or why not.
                // (\(encodedEndGoal))"
                ////                                )
                ////                            {
                ////                                print("\(output)")
                ////                                self.output = output
                ////                            }
                ////                        }
//                    }
//                }
            } label: {
                Text("Generate")
            }
        }
    }
}
