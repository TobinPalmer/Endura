import Foundation
import SwiftUI

struct GenerateTrainingGoalsView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel

    @State private var generationType = TrainingGenerationType.goal
    @State private var inputTextNotes = ""

    @State private var customEasyPace = 510.0

    @State private var output = ""

    @State private var progress = 0

    var body: some View {
        VStack {
            Text("Training Goal Generation")
                .font(.title)
                .fontWeight(.bold)
                .fontColor(.primary)
                .alignFullWidth()

            Text("This will generate training goals for you based on your end goal or a custom request.")
                .font(.body)
                .fontWeight(.bold)
                .fontColor(.secondary)
                .alignFullWidth()
                .padding(.vertical, 8)

            Picker("Generate for goal", selection: $generationType) {
                ForEach(TrainingGenerationType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            .pickerStyle(.segmented)

            switch generationType {
            case .goal:
                if let endGoal = activeUser.training.endTrainingGoal {
                    Text("""
                    This will generate the next \(endGoal.daysLeft()) days of training for your end goal
                    of getting \(FormattingUtils.formatMiles(endGoal.distance)) miles in
                    \(FormattingUtils.secondsToFormattedTimeColon(endGoal.time))
                    """)
                    .font(.body)
                    .fontWeight(.bold)
                    .fontColor(.primary)
                    .alignFullWidth()

                    Text("You can change your end goal in the profile tab.")
                        .font(.caption)
                        .fontColor(.secondary)
                        .alignFullWidth()

                    Text("Enter any notes or further requests you have for your training.")
                        .font(.body)
                        .fontWeight(.bold)
                        .fontColor(.primary)
                        .alignFullWidth()

                    TextField("Notes", text: $inputTextNotes)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text("No training goal")
                    NavigationLink(destination: TrainingEndGoalSetupView()) {
                        Text("Setup Training Goal")
                    }
                }
            case .custom:
                Text("Custom")

                Text("What is pace (per mile) do you want to run at for easy runs?")
                    .font(.body)
                    .fontWeight(.bold)
                    .fontColor(.primary)
                    .alignFullWidth()

                TimeInput(time: $customEasyPace, hours: false)

                Text(
                    "Enter what you want your training to be like. For example, \"I want to run 3-4 miles every day and improve core strength\""
                )
                .font(.body)
                .fontWeight(.bold)
                .fontColor(.primary)
                .alignFullWidth()
                TextField("Custom", text: $inputTextNotes)
                    .textFieldStyle(.roundedBorder)
            }

            Text(output)

            Spacer()

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
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate")
                }
            }
            .buttonStyle(EnduraNewButtonStyle())
        }
        .enduraPadding()
    }
}
