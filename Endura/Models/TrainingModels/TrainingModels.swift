import Foundation

public enum TrainingGoalData: Codable {
    case run(
        distance: Double,
        pace: Double,
        time: Double,
        difficulty: TrainingGoalDifficulty,
        runType: TrainingRunType
    )
    case postRun(
        time: Double,
        count: Int
    )
    case warmup(
        time: Double,
        count: Int
    )
}

public struct DailyTrainingData: Codable {
    public var type: TrainingDayType
    public var goals: [TrainingGoalData]
}

public struct WeeklyTrainingData: Codable {
    public var week: Date
    public var days: [Day: DailyTrainingData]
    public var dailySummary: [Day: DailySummaryData]
}

public struct UserTrainingData: Codable {
    public let weeklyTraining: [Date: String]
}
