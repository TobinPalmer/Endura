import Foundation
import GoogleGenerativeAI
import SwiftUICalendar

@MainActor public enum TrainingGenerationUtils {
    private static let api = GenerativeLanguage(apiKey: ProcessInfo.processInfo
        .environment["PALM_API_KEY"]!)

    public static func generateTrainingPlanForEndGoal(_ endGoal: TrainingEndGoalData) -> [TrainingRunGoalData] {
        let startDate = endGoal.startDate
        let endDate = endGoal.date
        let daysBetween = Calendar.current.dateComponents([.day], from: startDate.getDate(), to: endDate.getDate()).day!
        let days = (0 ... daysBetween).map { day in
            Calendar.current.date(byAdding: .day, value: day, to: startDate.getDate())!
        }
        let daysWithGoals = days.map { _ in
            TrainingRunGoalData(
                date: .current,
                workout: .time(time: endGoal.time)
            )
        }
        return daysWithGoals
    }

    private static func encodeExamples(_ examples: [(String, String)]) -> [Example] {
        examples.map { input, output in
            Example(input: Message(content: input, author: "0"), output: Message(content: output, author: "1"))
        }
    }

    public static func generateMultiOutputWithTrainingAI(
        inputs: [String],
        context: String?,
        examples: [(String, String)] = [],
        progress: @escaping (Int) -> Void
    ) async -> [String]? {
        do {
            var outputs: [String] = []
            var history: [Message] = []
            for input in inputs {
                let response = try await api.chat(
                    message: input,
                    history: history,
                    context: context,
                    examples: encodeExamples(examples)
                )
                print("\nResponse: \(response)")
                if let output = response.candidates?.first?.content {
                    outputs.append(output)
                    history.append(Message(content: input, author: "0"))
                    history.append(Message(content: output, author: "1"))
                }
                progress(Int(Double(outputs.count) / Double(inputs.count) * 100))
            }
            return outputs
        } catch {
            Global.log.error("Error generating multi output with ai: \(error)")
        }
        return nil
    }

    public static func generateWithTrainingAI(_ input: String) async -> String? {
        do {
            let response = try await GenerativeLanguage(apiKey: ProcessInfo.processInfo
                .environment["PALM_API_KEY"]!).generateText(with: input)
            if let candidate = response.candidates?.first, let text = candidate.output {
                return text
            }
        } catch {
            Global.log.error("Error generating with ai: \(error)")
        }
        return nil
    }

    public static func generateTrainingGoalsForEndGoal(activeUser: ActiveUserModel,
                                                       progress: @escaping (Int) -> Void) async
        -> [YearMonth: MonthlyTrainingData]?
    {
        guard let goal = activeUser.training.endTrainingGoal else {
            Global.log.error("No end goal found")
            return nil
        }
        let athleteInfo = TrainingGenerationDataUtils.encodeAthleteInfo(activeUser.data)
        let endGoal = TrainingGenerationDataUtils.encodeEndTrainingGoal(
            activeUser.training.endTrainingGoal!
        )
        let settings = TrainingGenerationDataUtils.encodeTrainingSettings(
            activeUser.settings.data.training
        )
        let context = TrainingGenerationPromptUtils.basicContext(
            athleteInfo: athleteInfo,
            goal: endGoal,
            settings: settings
        ) + TrainingGenerationPromptUtils.contextForDailyTrainingData()

        print("Context: \(context)")

        let inputs = TrainingGenerationPromptUtils.getDaysInWeeksBetween(
            .current,
            .current.addDay(value: 6)
//            goal.date
        ).map {
            TrainingGenerationPromptUtils.promptForDailyTrainingData($0)
        }
        print("\nInputs: \(inputs)\n")

//        let examples = TrainingGenerationPromptUtils.outputExamplesForDayTypes()

        if let outputs = await TrainingGenerationUtils.generateMultiOutputWithTrainingAI(
            inputs: inputs,
            context: context,
            progress: progress
        ) {
            let dayTypes = outputs
                .map {
                    print("\nOutput: \($0)\n")
                    return TrainingGenerationDataUtils.decodeDailyTrainingData($0)
                }

            print("\nDay types: \(dayTypes)\n")

//            var monthlyData: [YearMonth: MonthlyTrainingData] = activeUser.training.monthlyTrainingData
//            for day in dayTypes {
//
//            }
        }

        return [:]
    }
}
