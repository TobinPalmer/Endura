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

    public static func generateMultiOutputWithTrainingAI(
        inputs: [String],
        context: String?,
        progress: @escaping (Int) -> Void
    ) async -> [String]? {
        do {
            var outputs: [String] = []
            var history: [Message] = []
            for input in inputs {
                let response = try await api.chat(message: input, history: history, context: context)
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
        ) + TrainingGenerationPromptUtils.outputContextForDayTypes()

        print("Context: \(context)")

        let inputs = TrainingGenerationPromptUtils.getDaysBetween(
            .current,
            .current.addDay(value: 3)
        ).map {
            $0.toCache()
        }

        print("\nInputs: \(inputs)\n")

        if let outputs = await TrainingGenerationUtils.generateMultiOutputWithTrainingAI(
            inputs: inputs,
            context: context,
            progress: progress
        ) {
            let dayTypes = outputs
                .map {
                    print("\nOutput: \($0)\n")
                    TrainingGenerationDataUtils.decodeTrainingDayType($0)
                }

            for day in dayTypes {
                print("Day: \(day)")
            }
        }

//        var monthlyData: [YearMonth: MonthlyTrainingData] = activeUser.training.monthlyTrainingData

        return [:]
    }
}
