import Foundation
import SwiftUI
import SwiftUICalendar

public enum DistanceType: Double, Codable, CaseIterable {
    case miles = 1609.34
    case kilometers = 1000
    case meters = 1

    public func getUnit() -> String {
        switch self {
        case .miles:
            return "mi"
        case .kilometers:
            return "km"
        case .meters:
            return "m"
        }
    }

    public func convertUnit(value: Double, to: DistanceType) -> Double {
        value * to.rawValue / rawValue
    }
}

public enum TrainingGoalType: String, Codable {
    case warmup = "Warmup"
    case running = "Running"
    case postRun = "Post Run"
}

public enum TrainingRunType: String, Codable, CaseIterable {
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

    public func toTrainingDayType() -> TrainingDayType {
        switch self {
        case .none:
            return .none
        case .easy:
            return .easy
        case .normal:
            return .medium
        case .long:
            return .long
        case .workout:
            return .workout
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
