import Foundation

protocol TrainingGoalBase {
    var type: TrainingGoalType { get }
    var time: Double { get }
}

public struct RunningTrainingGoal: Codable, TrainingGoalBase {
    public let difficulty: TrainingGoalDifficulty
    public let distance: Double
    public let pace: Double
    public let runType: TrainingRunType
    public let time: Double
    public let type: TrainingGoalType
}

public struct PostRunTrainingGoal: Codable, TrainingGoalBase {
    public let type: TrainingGoalType
    public let count: Int
    public let time: Double
}

public struct WarmupTrainingGoal: Codable, TrainingGoalBase {
    public let type: TrainingGoalType
    public let count: Int
    public let time: Double
}

public struct DailyTrainingData: Codable {
    public let day: Days
    public let completed: Bool
}

public struct WeeklyTrainingData: Codable {
    public let weekId: String
    public let scheduledTraining: [DailyTrainingData]
}
