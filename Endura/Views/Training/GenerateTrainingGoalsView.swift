import Foundation
import SwiftUI

struct GenerateTrainingGoalsView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel

    @State private var output = ""

    @State private var progress = 0

    var body: some View {
        VStack {
            Text("Generate Training Goals!")

            Text(output)

            ProgressView(value: Double(progress), total: 100)
                .padding(.vertical, 20)

            Button {
                Task {
                    if let encodedData = TrainingGenerationDataUtils
                        .encodeTrainingPlan(activeUser.training.monthlyTrainingData)
                    {
                        print("\n\nEncodedData:\n\(encodedData)\n\n")
                    }
                    let trainingData = await TrainingGenerationUtils.generateTrainingGoalsForEndGoal(
                        activeUser: activeUser,
                        progress: { progress in
                            print("Progress: \(progress)")
                            withAnimation {
                                self.progress = progress
                            }
                        }
                    )
                    if let trainingData = trainingData {
                        print("Training data: \(trainingData)")
                        DispatchQueue.main.async {
                            activeUser.training.monthlyTrainingData = trainingData
                        }
                    }
                }
            } label: {
                Text("Generate")
            }
        }
    }
}
