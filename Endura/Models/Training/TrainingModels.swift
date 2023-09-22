import Foundation
import SwiftUI
import SwiftUICalendar

public enum TrainingGoalData: Codable, Hashable, Cacheable {
    case run(
        type: TrainingRunType,
        distance: Double,
        pace: Double,
        time: Double
    )
    case routine(
        type: RoutineType,
        difficulty: RoutineDifficulty,
        time: Double,
        count: Int
    )

    public func getTitle() -> String {
        switch self {
        case let .run(type, _, _, _):
            return type.rawValue
        case let .routine(type, _, _, _):
            return type.rawValue
        }
    }

    public func getIcon() -> String {
        switch self {
        case .run:
            return "figure.run"
        case let .routine(type, _, _, _):
            switch type {
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
        case let .routine(type, _, _, _):
            switch type {
            case .warmup:
                return .green
            case .postrun:
                return .red
            }
        }
    }

    func updateCache(_ cache: TrainingGoalCache) {
        switch self {
        case let .run(type, distance, pace, time):
            cache.goalType = "run"
            cache.type = type.rawValue
            cache.distance = distance
            cache.pace = pace
            cache.time = time
        case let .routine(type, difficulty, time, count):
            cache.goalType = "routine"
            cache.type = type.rawValue
            cache.difficulty = difficulty.rawValue
            cache.time = time
            cache.count = Int16(count)
        }
    }

    static func fromCache(_ cache: TrainingGoalCache) -> Self {
        switch cache.goalType {
        case "run":
            return .run(
                type: TrainingRunType(rawValue: cache.type ?? "none") ?? .none,
                distance: cache.distance,
                pace: cache.pace,
                time: cache.time
            )
        case "routine":
            return .routine(
                type: RoutineType(rawValue: cache.type ?? "none") ?? .postrun,
                difficulty: RoutineDifficulty(rawValue: cache.difficulty ?? "none") ?? .medium,
                time: cache.time,
                count: Int(cache.count)
            )
        default:
            return .run(
                type: TrainingRunType(rawValue: cache.type ?? "none") ?? .none,
                distance: cache.distance,
                pace: cache.pace,
                time: cache.time
            )
        }
    }
}

public struct DailyTrainingData: Cacheable {
    public var date: YearMonthDay
    public var type: TrainingDayType
    public var goals: [TrainingGoalData]
    public var summary: DailySummaryData?

    func updateCache(_ cache: DailyTrainingCache) {
        cache.date = date.toCache()
        cache.type = type.rawValue
        cache.removeFromGoals(cache.goals ?? NSSet())
        cache.addToGoals(NSSet(array: goals.map { goal in
            let cache = TrainingGoalCache(context: cache.managedObjectContext!)
            goal.updateCache(cache)
            return cache
        }))
    }

    static func fromCache(_ cache: DailyTrainingCache) -> Self {
        DailyTrainingData(
            date: YearMonthDay.fromCache(cache.date ?? ""),
            type: TrainingDayType(rawValue: cache.type ?? "none") ?? .none,
            goals: cache.goals?.map { goal in
                TrainingGoalData.fromCache(goal as! TrainingGoalCache)
            } ?? []
        )
    }
}

public struct DailyTrainingDataDocument: Codable {
    public var date: Date
    public var type: TrainingDayType
    public var goals: [TrainingGoalData]
    public var summary: DailySummaryData?
}

public struct MonthlyTrainingData: Cacheable {
    public var date: YearMonth
    public var totalDistance: Double
    public var totalDuration: Double
    public var days: [YearMonthDay: DailyTrainingData]

    func updateCache(_ cache: MonthlyTrainingCache) {
        cache.date = date.toCache()
        cache.totalDistance = totalDistance
        cache.totalDuration = totalDuration
        cache.removeFromDays(cache.days ?? NSSet())
        cache.addToDays(NSSet(array: days.map { _, data in
            let cache = DailyTrainingCache(context: cache.managedObjectContext!)
            data.updateCache(cache)
            return cache
        }))
    }

    static func fromCache(_ cache: MonthlyTrainingCache) -> Self {
        MonthlyTrainingData(
            date: YearMonth.fromCache(cache.date ?? ""),
            totalDistance: cache.totalDistance,
            totalDuration: cache.totalDuration,
            days: cache.days?.reduce(into: [:]) { dict, day in
                dict[YearMonthDay.fromCache((day as! DailyTrainingCache).date ?? "")] = DailyTrainingData.fromCache(day as! DailyTrainingCache)
            } ?? [:]
        )
    }
}

public struct MonthlyTrainingDataDocument: Codable {
    public var totalDistance: Double
    public var totalDuration: Double
    public var days: [String: DailyTrainingDataDocument]
}

public struct RunningSchedule: Codable {
    public var day: Int
    public var type: RunningScheduleType
}
