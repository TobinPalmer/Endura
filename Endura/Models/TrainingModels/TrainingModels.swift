import Foundation

protocol TrainingGoalBase {
    var type: TrainingGoalType { get }
    var time: Double { get }
}

public struct RunningTrainingGoal: Codable, TrainingGoalBase {
    public var difficulty: TrainingGoalDifficulty
    public var distance: Double
    public var pace: Double
    public var runType: TrainingRunType
    public var time: Double
    public var type: TrainingGoalType
}

public struct PostRunTrainingGoal: Codable, TrainingGoalBase {
    public var type: TrainingGoalType
    public var count: Int
    public var time: Double
}

public struct WarmupTrainingGoal: Codable, TrainingGoalBase {
    public var type: TrainingGoalType
    public var count: Int
    public var time: Double
}

public struct DailyTrainingData: Codable {
    public var day: Days
    public var completed: Bool
}

public struct WeeklyTrainingData: Codable {
    public var weekId: String
    public var scheduledTraining: [DailyTrainingData]
}
