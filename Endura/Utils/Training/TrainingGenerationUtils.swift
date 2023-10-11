import Foundation
import GoogleGenerativeAI

public enum TrainingGenerationUtils {
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
}
