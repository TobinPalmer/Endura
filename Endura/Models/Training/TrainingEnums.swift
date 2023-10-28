import Foundation
import SwiftUI
import SwiftUICalendar

public enum TrainingGoalType: String, Codable {
    case warmup = "Warmup"
    case running = "Running"
    case postRun = "Post Run"
}

public enum TrainingRunType: String, Codable {
    case none = "None"
    case easy = "Easy"
    case normal = "Medium"
    case long = "Long"
    case workout = "Workout"

    public func getColor() -> Color {
        switch self {
        case .easy:
            return Color("EnduraGreen")
        case .normal:
            return Color("EnduraYellow")
        case .long:
            return Color("EnduraOrange")
        case .workout:
            return Color("EnduraRed")
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
            return Color("EnduraBlue")
        case .easy:
            return Color("EnduraGreen")
        case .medium:
            return Color("EnduraYellow")
        case .long:
            return Color("EnduraOrange")
        case .workout:
            return Color("EnduraRed")
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
