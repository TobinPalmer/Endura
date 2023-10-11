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

    func updateCache(_ cache: TrainingGoalCache) {
        cache.date = date.toCache()
        cache.goalType = "run"
        switch workout {
        case .open:
            cache.workoutType = "open"
        case let .distance(distance):
            cache.workoutType = "distance"
            cache.distance = distance
        case let .time(time):
            cache.workoutType = "time"
            cache.time = time
        case let .pacer(distance, time):
            cache.workoutType = "pacer"
            cache.distance = distance
            cache.time = time
        case let .custom(data):
            cache.workoutType = "custom"
        }
        cache.progressCompleted = progress.completed
        cache.progressActivity = progress.activity
    }

    static func fromCache(_ cache: TrainingGoalCache) -> Self {
        TrainingRunGoalData(
            date: YearMonthDay.fromCache(cache.date ?? ""),
            workout: WorkoutGoalData.fromCache(cache),
            progress: TrainingGoalProgressData(
                completed: cache.progressCompleted,
                activity: cache.progressActivity
            )
        )
    }
}

public struct TrainingRunGoalDataDocument: Codable, Hashable {
    public var date: String
    public var preRoutine: TrainingRoutineGoalData?
    public var workout: WorkoutGoalData
    public var postRoutine: TrainingRoutineGoalData?
    public var progress: TrainingGoalProgressData?

    init(_ data: TrainingRunGoalData) {
        date = data.date.toCache()
        preRoutine = data.preRoutine
        workout = data.workout
        postRoutine = data.postRoutine
        progress = data.progress
    }

    public func toTrainingRunGoalData() -> TrainingRunGoalData {
        TrainingRunGoalData(
            date: YearMonthDay.fromCache(date),
            preRoutine: preRoutine,
            workout: workout,
            postRoutine: postRoutine,
            progress: progress ?? .init(completed: false, activity: nil)
        )
    }
}
