import Foundation

public enum TrainingGoalType: String, Codable {
    case warmup = "Warmup"
    case running = "Running"
    case postRun = "Post Run"
}

public enum TrainingRunType: String, Codable {
    case long = "Long Run"
    case hard = "Hard Run"
    case normal = "Normal Run"
    case workout = "Workout Run"
    case none
}

public enum TrainingGoalDifficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

public enum TrainingDayType: String, Codable {
    case rest = "Rest"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}
