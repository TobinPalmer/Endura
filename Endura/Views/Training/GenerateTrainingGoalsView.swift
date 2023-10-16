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
                    let trainingData = await TrainingGenerationUtils.generateTrainingGoalsForEndGoal(
                        activeUser: activeUser,
                        progress: { progress in
                            withAnimation {
                                self.progress = progress
                            }
                        }
                    )
                    if let trainingData = trainingData {
                        DispatchQueue.main.async {
                            for month in trainingData {
                                activeUser.training.monthlyTrainingData.updateValue(month.value, forKey: month.key)
                                activeUser.training.saveTrainingMonth(month.key)
                            }
                        }
                    }
                }
            } label: {
                Text("Generate")
            }
        }
    }
}
