import Foundation
import SwiftUI
import SwiftUICalendar
import WorkoutKit

public struct TrainingGoalProgressData: Codable, Hashable {
    public var completed: Bool
    public var activity: String?
}

public struct TrainingRoutineGoalData: Codable, Hashable {
    public var type: RoutineType
    public var difficulty: RoutineDifficulty
    public var progress: TrainingGoalProgressData = .init(completed: false, activity: nil)
}

public struct TrainingRunGoalData: Hashable {
    public var uuid: String? = UUID().uuidString
    public var date: YearMonthDay
    public var type: TrainingRunType = .none
    public var description: String = ""
    public var preRoutine: TrainingRoutineGoalData?
    public var workout: WorkoutGoalData = .distance(distance: 0)
    public var postRoutine: TrainingRoutineGoalData?
    public var progress: TrainingGoalProgressData = .init(completed: false, activity: nil)

    public func getDistance() -> Double {
        switch workout {
        case .open:
            return 0
        case let .distance(distance):
            return distance
        case let .time(time):
            return 0
        case let .pacer(distance, time):
            return distance
        case let .custom(data):
            return data.getDistance()
        }
    }

    public func getTime() -> Double {
        switch workout {
        case .open:
            return 0
        case let .distance(distance):
            return 0
        case let .time(time):
            return time
        case let .pacer(distance, time):
            return time
        case let .custom(data):
            return data.getTime()
        }
    }

    public func getTitle() -> String {
        switch workout {
        case .open:
            return "Open Run"
        case let .distance(distance):
            return "\(FormattingUtils.formatMiles(distance)) Mile Run"
        case let .time(time):
            return "\(FormattingUtils.secondsToFormattedTime(time)) Run"
        case let .pacer(distance, time):
            return "\(FormattingUtils.formatMiles(distance)) Mile Run in \(FormattingUtils.secondsToFormattedTime(time))"
        case let .custom(data):
            return "Custom Workout"
        }
    }

    public func getRoutine(routineType: RoutineType) -> TrainingRoutineGoalData? {
        var difficulty = RoutineDifficulty.none
        switch type {
        case .none:
            return nil
        case .easy:
            difficulty = .easy
        case .normal:
            difficulty = .medium
        case .long,
             .workout:
            difficulty = .hard
        }
        switch routineType {
        case .warmup:
            return TrainingRoutineGoalData(
                type: .warmup,
                difficulty: difficulty,
                progress: .init(completed: false, activity: nil)
            )
        case .postRun:
            return TrainingRoutineGoalData(
                type: .postRun,
                difficulty: difficulty,
                progress: .init(completed: false, activity: nil)
            )
        }
    }
}
