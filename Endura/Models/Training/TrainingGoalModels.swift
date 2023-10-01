import Foundation
import SwiftUI
import SwiftUICalendar
import WorkoutKit

public struct RunningTrainingGoalData: Codable, Hashable {
    public var uuid: String? = UUID().uuidString
    public var date: Date
    public var type: TrainingRunType = .none
    public var workout: WorkoutGoalData = .distance(distance: 0)
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
}

public struct RoutineTrainingGoalData: Codable, Hashable {
    public var uuid: String? = UUID().uuidString
    public var date: Date
    public var type: RoutineType
    public var difficulty: RoutineDifficulty
    public var time: Double
    public var count: Int
    public var progress: TrainingGoalProgressData = .init(completed: false, activity: nil)
}

public struct TrainingGoalProgressData: Codable, Hashable {
    public var completed: Bool
    public var activity: String?
}

public enum TrainingGoalData: Codable, Hashable, Cacheable {
    case run(
        data: RunningTrainingGoalData
    )
    case routine(
        data: RoutineTrainingGoalData
    )

    public func getUUID() -> String {
        switch self {
        case let .run(data):
            return data.uuid!
        case let .routine(data):
            return data.uuid!
        }
    }

    public func getTitle() -> String {
        switch self {
        case let .run(data):
            return data.type.rawValue
        case let .routine(data):
            return data.type.rawValue
        }
    }

    public func getIcon() -> String {
        switch self {
        case .run:
            return "figure.run"
        case let .routine(data):
            switch data.type {
            case .warmup:
                return "figure.cooldown"
            case .postrun:
                return "figure.strengthtraining.functional"
            }
        }
    }

    public func getColor() -> Color {
        switch self {
        case .run:
            return .blue
        case let .routine(data):
            switch data.type {
            case .warmup:
                return .green
            case .postrun:
                return .red
            }
        }
    }

    public func getBackgroundColor() -> Color {
        getColor().opacity(0.2)
    }

    func updateCache(_ cache: TrainingGoalCache) {
        switch self {
        case let .run(data):
            cache.date = data.date
            cache.goalType = "run"
            cache.type = data.type.rawValue
            cache.progressCompleted = data.progress.completed
            cache.progressActivity = data.progress.activity
        case let .routine(data):
            cache.date = data.date
            cache.goalType = "routine"
            cache.type = data.type.rawValue
            cache.difficulty = data.difficulty.rawValue
            cache.time = data.time
            cache.count = Int16(data.count)
            cache.progressCompleted = data.progress.completed
            cache.progressActivity = data.progress.activity
        }
    }

    static func fromCache(_ cache: TrainingGoalCache) -> Self {
        switch cache.goalType {
        case "run":
            return .run(
                data: RunningTrainingGoalData(
                    date: cache.date ?? Date(),
                    type: TrainingRunType(rawValue: cache.type ?? "none") ?? .none,
                    workout: .distance(distance: 1),
                    progress: TrainingGoalProgressData(
                        completed: cache.progressCompleted ?? false,
                        activity: cache.progressActivity
                    )
                )
            )
        case "routine":
            return .routine(
                data: RoutineTrainingGoalData(
                    date: cache.date ?? Date(),
                    type: RoutineType(rawValue: cache.type ?? "none") ?? .postrun,
                    difficulty: RoutineDifficulty(rawValue: cache.difficulty ?? "none") ?? .medium,
                    time: cache.time,
                    count: Int(cache.count),
                    progress: TrainingGoalProgressData(
                        completed: cache.progressCompleted ?? false,
                        activity: cache.progressActivity
                    )
                )
            )
        default:
            return .run(
                data: RunningTrainingGoalData(
                    date: Date(),
                    type: .none,
                    workout: .distance(distance: 0)
                )
            )
        }
    }
}
