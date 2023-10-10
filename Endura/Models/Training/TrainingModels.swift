import Foundation
import SwiftUI
import SwiftUICalendar

public struct DailyTrainingData: Cacheable {
    public var date: YearMonthDay
    public var type: TrainingDayType
    public var goals: [TrainingGoalData] = []
    public var summary: DailySummaryData = .init(distance: 0, duration: 70, activities: 0)

    func updateCache(_ cache: DailyTrainingCache) {
        cache.date = date.toCache()
        cache.type = type.rawValue
        cache.removeFromGoals(cache.goals ?? NSSet())
        cache.addToGoals(NSSet(array: goals.map { goal in
            let cache = TrainingGoalCache(context: cache.managedObjectContext!)
            goal.updateCache(cache)
            return cache
        }))
        cache.summaryDistance = summary.distance
        cache.summaryDuration = summary.duration
        cache.summaryActivities = Int16(summary.activities)
    }

    static func fromCache(_ cache: DailyTrainingCache) -> Self {
        DailyTrainingData(
            date: YearMonthDay.fromCache(cache.date ?? ""),
            type: TrainingDayType(rawValue: cache.type ?? "none") ?? .none,
            goals: cache.goals?.map { goal in
                TrainingGoalData.fromCache(goal as! TrainingGoalCache)
            } ?? [],
            summary: DailySummaryData(
                distance: cache.summaryDistance,
                duration: cache.summaryDuration,
                activities: Int(cache.summaryActivities)
            )
        )
    }
}

public struct DailyTrainingDataDocument: Codable {
    public var date: String
    public var type: TrainingDayType
    public var goals: [TrainingGoalData]
    public var summary: DailySummaryData?
}

public struct MonthlyTrainingData: Cacheable, Equatable {
    public var date: YearMonth
    public var totalDistance: Double = 0
    public var totalDuration: Double = 0
    public var days: [YearMonthDay: DailyTrainingData] = [:]

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
                dict[YearMonthDay.fromCache((day as! DailyTrainingCache).date ?? "")] = DailyTrainingData
                    .fromCache(day as! DailyTrainingCache)
            } ?? [:]
        )
    }

    public static func == (lhs: MonthlyTrainingData, rhs: MonthlyTrainingData) -> Bool {
        lhs.date == rhs.date && lhs.totalDistance == rhs.totalDistance && lhs.totalDuration == rhs.totalDuration && rhs
            .days.isEmpty
    }
}

public struct MonthlyTrainingDataDocument: Codable {
    public var totalDistance: Double
    public var totalDuration: Double
    public var days: [String: DailyTrainingDataDocument]

    public init(_ data: MonthlyTrainingData) {
        totalDistance = data.totalDistance
        totalDuration = data.totalDuration
        days = data.days.reduce(into: [:]) { dict, day in
            dict[day.key.toCache()] = DailyTrainingDataDocument(
                date: day.value.date.toCache(),
                type: day.value.type,
                goals: day.value.goals,
                summary: day.value.summary
            )
        }
    }

    public func toMonthlyTrainingData() -> MonthlyTrainingData {
        MonthlyTrainingData(
            date: YearMonth.fromCache(days.first!.key),
            totalDistance: totalDistance,
            totalDuration: totalDuration,
            days: days.reduce(into: [:]) { dict, day in
                dict[YearMonthDay.fromCache(day.key)] = DailyTrainingData(
                    date: YearMonthDay.fromCache(day.value.date),
                    type: day.value.type,
                    goals: day.value.goals,
                    summary: day.value.summary ?? .init(distance: 0, duration: 0, activities: 0)
                )
            }
        )
    }
}

public struct RunningSchedule: Codable {
    public var day: Int
    public var type: RunningScheduleType
}
