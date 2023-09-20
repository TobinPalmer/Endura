import Foundation
import SwiftUICalendar

public enum TrainingGoalData: Codable, Hashable, Cacheable {
    case run(
        type: TrainingRunType,
        distance: Double,
        pace: Double,
        time: Double
    )
    case postRun(
        type: PostRunType,
        time: Double,
        count: Int
    )
    case warmup(
        time: Double,
        count: Int
    )

    func updateCache(_ cache: TrainingGoalCache) {
        switch self {
        case let .run(type, distance, pace, time):
            cache.goalType = "run"
            cache.type = type.rawValue
            cache.distance = distance
            cache.pace = pace
            cache.time = time
        case let .postRun(type, time, count):
            cache.goalType = "postRun"
            cache.type = type.rawValue
            cache.time = time
            cache.count = Int16(count)
        case let .warmup(time, count):
            cache.type = "warmup"
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
        case "postRun":
            return .postRun(
                type: PostRunType(rawValue: cache.type ?? "none") ?? .none,
                time: cache.time,
                count: Int(cache.count)
            )
        case "warmup":
            return .warmup(
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
