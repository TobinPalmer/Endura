import Foundation
import SwiftUI
import SwiftUICalendar

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
    case none = "None"
    case rest = "Rest"
    case easy = "Easy"
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
        case .long:
            return .orange
        case .workout:
            return .red
        }
    }

    public static var allCases: [TrainingDayType] {
        [.none, .rest, .easy, .long, .workout]
    }
}

public enum TrainingDayAvailability: String, Codable {
    case busy = "Busy"
    case maybe = "Maybe"
    case free = "Free"
}
