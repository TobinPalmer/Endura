import Foundation

public enum Days: String, Codable, CaseIterable {
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    case sunday = "Sun"
}

public enum TrainingGoalType: String, Codable {
    case running
    case postRun
}

public struct RunningTrainingGoal: Codable {
    public var type: TrainingGoalType
    public var distance: Double
    public var time: Double
    public var pace: Double
}

public struct PostRunTrainingGoal: Codable {
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
