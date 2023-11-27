import Foundation
import GoogleGenerativeAI
import SwiftUICalendar

@MainActor public enum TrainingGenerationUtils {
    private static let api = GenerativeLanguage(apiKey: "AIzaSyDOdxt6TaUhDYTKdAM3FqwDcBdPhGRWssM")

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

    public static func generateTrainingGoals(activeUser: ActiveUserModel,
                                             generationType: TrainingGenerationType,
                                             infoText: String = "",
                                             customOptions: TrainingGenerationCustomOptions? = nil,
                                             progress: @escaping (Int) -> Void) async
        -> [YearMonth: MonthlyTrainingData]?
    {
        let athleteInfo = TrainingGenerationDataUtils.encodeAthleteInfo(activeUser.data)
        let settings = TrainingGenerationDataUtils.encodeTrainingSettings(
            activeUser.settings.data.training,
            activeUser.training.endTrainingGoal!
        )

        var context = ""
        var goalDate = YearMonthDay.current.addDay(value: 7)
        if generationType == .goal {
            guard let goal = activeUser.training.endTrainingGoal else {
                Global.log.error("No end goal found")
                return nil
            }
            let endGoal = TrainingGenerationDataUtils.encodeEndTrainingGoal(
                activeUser.training.endTrainingGoal!
            )
            goalDate = goal.date
            context = TrainingGenerationPromptUtils.basicContextForEndGoal(
                athleteInfo: athleteInfo,
                goal: endGoal,
                trainingInfo: settings
            ) + TrainingGenerationPromptUtils.contextForDailyTrainingData()
        } else {
            guard let customOptions = customOptions else {
                Global.log.error("No custom options found")
                return nil
            }
            goalDate = customOptions.endDate
            context = TrainingGenerationPromptUtils.basicContextForCustom(
                athleteInfo: athleteInfo,
                infoText: infoText,
                trainingInfo: settings
            ) + TrainingGenerationPromptUtils.contextForDailyTrainingData()
        }

        let inputs = TrainingGenerationPromptUtils.getDaysInWeeksBetween(
            .current,
            goalDate
        ).map {
            TrainingGenerationPromptUtils.promptForDailyTrainingData(
                $0[0].toCache(),
                extraReference: settings + "\n The first day below is a \($0[0].dayOfWeek)"
            )
        }

        progress(10)

        if let outputs = await TrainingGenerationUtils.generateMultiOutputWithTrainingAI(
            inputs: inputs,
            context: context,
            progress: progress
        ) {
            var generatedDailyData: [DailyTrainingData] = []
            outputs.forEach {
                var pace = 480.0
                var dist = 3.0
                if let endGoal = activeUser.training.endTrainingGoal {
                    pace = endGoal.time / endGoal.distance
                    dist = endGoal.distance
                }
                return generatedDailyData.append(contentsOf: TrainingGenerationDataUtils.decodeDailyTrainingData(
                    $0,
                    pace: pace,
                    goalDist: dist
                ))
            }

            progress(80)
            var monthlyData: [YearMonth: MonthlyTrainingData] = [:]
            for day in generatedDailyData {
                let date = day.date
                let yearMonth = YearMonth(year: date.year, month: date.month)
                if monthlyData[yearMonth] == nil {
                    monthlyData.updateValue(
                        activeUser.training
                            .monthlyTrainingData[yearMonth] ?? MonthlyTrainingData(date: yearMonth),
                        forKey: yearMonth
                    )
                }
                monthlyData[yearMonth]!.days.updateValue(day, forKey: day.date)
            }
            progress(100)
            return monthlyData
        }

        return [:]
    }

    public static func generatePostRunRoutine(activeUser: ActiveUserModel) async
        -> RoutineData?
    {
        let athleteInfo = TrainingGenerationDataUtils.encodeAthleteInfo(activeUser.data)

        let prompt = TrainingGenerationPromptUtils.promptForRoutinePlan(
            .postRun,
            athleteInfo: athleteInfo,
            lastRunInfo: ""
        )

        print("Prompt: \n\n\(prompt)\n\n")

        if let output = await TrainingGenerationUtils.generateWithTrainingAI(prompt) {
            return TrainingGenerationDataUtils.decodeRoutineData(output)
        }

        return nil
    }
}
