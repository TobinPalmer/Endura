import Foundation
import SwiftUI
import SwiftUICalendar

public struct TrainingGenerationCustomOptions {
    public var easyPace: Double = 510
    public var hardPace: Double = 420
    public var endDate: YearMonthDay
    public var notes: String
}

struct GenerateTrainingGoalsView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @Environment(\.dismiss) private var dismiss

    @State private var generationType = TrainingGenerationType.goal
    @State private var endGoalNotes = ""

    @State private var customOptions = TrainingGenerationCustomOptions(
        endDate: .current.addDay(value: 7),
        notes: ""
    )

    @State private var output = ""

    @State private var progress = 0
    @State private var generationTask: Task<Void, Never>? = nil

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Text("This will generate training goals for you based on your end goal or a custom request.")
                    .font(.body)
                    .fontColor(.primary)
                    .alignFullWidth()

                Picker("Generate for goal", selection: $generationType) {
                    ForEach(TrainingGenerationType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)

                Divider()
                    .padding(.bottom, 10)

                switch generationType {
                case .goal:
                    if let endGoal = activeUser.training.endTrainingGoal {
//                    Text(
//                        "This will generate the next \(endGoal.daysLeft()) days to help you reach your end goal by
//                        \(FormattingUtils.dateToFormattedDay(endGoal.date)). Your current end goal is getting
//                        \(FormattingUtils.formatMiles(endGoal.distance)) miles in
//                        \(FormattingUtils.secondsToFormattedTimeColon(endGoal.time))."
//                    )
//                        .font(.body)
//                        .fontColor(.secondary)
//                        .alignFullWidth()

                        Text("This will generate a training plan to help you reach your end goal.")
                            .font(.body)
                            .fontColor(.primary)
                            .alignFullWidth()
                        EndGoalProgressCard()
//                    Text("You can change your end goal in the profile tab.")
//                        .font(.caption)
//                        .fontColor(.secondary)
//                        .alignFullWidth()

                        Text("Enter any notes or further requests you have for your training.")
                            .font(.body)
                            .fontColor(.primary)
                            .alignFullWidth()
                            .padding(.top, 10)

                        TextField("Notes or training requests...", text: $endGoalNotes, axis: .vertical)
                            .lineLimit(4 ... 6)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text("No training goal")
                        NavigationLink(destination: TrainingEndGoalSetupView()) {
                            Text("Setup Training Goal")
                        }
                    }
                case .custom:
                    Text("How far do you want to generate this training plan for?")
                        .font(.body)
                        .fontColor(.primary)
                        .alignFullWidth()

                    DatePicker(
                        selection: Binding<Date>(
                            get: { customOptions.endDate.getDate() },
                            set: { customOptions.endDate = $0.toYearMonthDay() }
                        ),
                        in: Date()...,
                        displayedComponents: [.date]
                    ) {
                        Label("Completion Date", systemImage: "calendar")
                            .font(.body)
                            .fontColor(.primary)
                    }

                    Text("Please input your paces for accurate training.")
                        .font(.body)
                        .fontColor(.primary)
                        .alignFullWidth()
                        .padding(.top, 10)
                        .padding(.bottom, 4)

                    VStack(spacing: 4) {
                        HStack {
                            Label("Easy Pace", systemImage: "timer")
                                .font(.body)
                                .fontColor(.primary)

                            Spacer()

                            TimeInput(time: $customOptions.easyPace, hours: false)
                        }
                        HStack {
                            Label("Hard Pace", systemImage: "timer")
                                .font(.body)
                                .fontColor(.primary)

                            Spacer()

                            TimeInput(time: $customOptions.hardPace, hours: false)
                        }
                    }
                    .padding(.bottom, 10)

                    Text(
                        "Enter what you want your training to be like. For example, \"I want to run 3-4 miles every day and improve core strength\""
                    )
                    .font(.body)
                    .fontColor(.primary)
                    .alignFullWidth()
                    TextField(
                        "Enter your goal and requests for training here...",
                        text: $customOptions.notes,
                        axis: .vertical
                    )
                    .lineLimit(4 ... 6)
                    .textFieldStyle(.roundedBorder)
                }

                Text(output)

                if progress > 0 {
                    ProgressView(value: Double(progress), total: 100)
                        .animation(.easeInOut(duration: 5))
                        .padding(.top, 10)
                }

                if generationTask != nil {
                    Button {
                        generationTask?.cancel()
                        generationTask = nil
                        progress = 0
                    } label: {
                        HStack {
                            ProgressView()
                            Text("Generating, Click to Cancel")
                                .padding(.leading, 10)
                        }
                    }
                    .buttonStyle(EnduraNewButtonStyle())
                } else {
                    Button {
                        generationTask = Task {
                            progress = 0
                            let trainingData = await TrainingGenerationUtils.generateTrainingGoals(
                                activeUser: activeUser,
                                generationType: generationType,
                                infoText: generationType == .goal ? endGoalNotes : customOptions.notes,
                                customOptions: customOptions,
                                progress: { progress in
                                    withAnimation {
                                        self.progress = progress
                                    }
                                }
                            )
                            if let trainingData = trainingData {
                                DispatchQueue.main.async {
                                    for month in trainingData {
                                        print("Generated \(month.key) with \(month.value.days.count) days")
                                        activeUser.training.monthlyTrainingData.updateValue(
                                            month.value,
                                            forKey: month.key
                                        )
                                        activeUser.training.saveTrainingMonth(month.key)
                                        if generationTask != nil {
                                            generationTask = nil
                                            dismiss()
                                        }
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
            }
            .enduraPadding()
            .navigationBarTitle("Generate Training Goals", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {} label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
    }
}
