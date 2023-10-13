import Foundation
import SwiftUI
import SwiftUICalendar

public enum TrainingGoalType: String, Codable {
    case warmup = "Warmup"
    case running = "Running"
    case postRun = "Post Run"
}

public enum TrainingRunType: String, Codable {
    case none
    case hard = "Easy Run"
    case normal = "Medium Run"
    case long = "Long Run"
    case workout = "Workout Run"

    public func getColor() -> Color {
        switch self {
        case .hard:
            return .green
        case .normal:
            return .yellow
        case .long:
            return .orange
        case .workout:
            return .red
        case .none:
            return .gray
        }
    }
}

public enum TrainingGoalDifficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

public enum TrainingDayType: String, Codable {
    case none = "None"
    case rest = "Rest"
    case easy = "Easy"
    case medium = "Medium"
    case long = "Long"
    case workout = "Workout"

    public func getColor() -> Color {
        switch self {
        case .none:
            return .gray
        case .rest:
            return .blue
        case .easy:
            return .green
        case .medium:
            return .yellow
        case .long:
            return .orange
        case .workout:
            return .red
        }
    }

    public static var allCases: [TrainingDayType] {
        [.none, .rest, .easy, .medium, .long, .workout]
    }
}

public enum TrainingDayAvailability: String, Codable {
    case busy = "Busy"
    case free = "Free"
}
