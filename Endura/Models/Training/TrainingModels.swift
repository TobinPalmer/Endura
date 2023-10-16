import Foundation
import SwiftUI
import SwiftUICalendar

public struct DailyTrainingData: Cacheable {
    public var date: YearMonthDay
    public var type: TrainingDayType
    public var goals: [TrainingRunGoalData] = []
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
                TrainingRunGoalData.fromCache(goal as! TrainingGoalCache)
            } ?? [],
            summary: DailySummaryData(
                distance: cache.summaryDistance,
                duration: cache.summaryDuration,
                activities: Int(cache.summaryActivities)
            )
        )
    }

    public func getDocument() -> DailyTrainingDataDocument {
        DailyTrainingDataDocument(
            date: date.toCache(),
            type: type,
            goals: goals.map { goal in
                TrainingRunGoalDataDocument(goal)
            },
            summary: summary
        )
    }

    public static func fromDocument(_ document: DailyTrainingDataDocument) -> Self {
        DailyTrainingData(
            date: YearMonthDay.fromCache(document.date),
            type: document.type,
            goals: document.goals.map { goal in
                goal.toTrainingRunGoalData()
            },
            summary: document.summary ?? .init(distance: 0, duration: 0, activities: 0)
        )
    }
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
            dict[day.key.toCache()] = day.value.getDocument()
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
                    goals: day.value.goals.map { goal in
                        goal.toTrainingRunGoalData()
                    },
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

public extension WorkoutGoalData {
    static func fromCache(_ cache: TrainingGoalCache) -> WorkoutGoalData {
        switch cache.workoutType {
        case "distance":
            return .distance(distance: cache.distance)
        case "time":
            return .time(time: cache.time)
        case "pacer":
            return .pacer(distance: cache.distance, time: cache.time)
        case "custom":
            return .custom(data: CustomWorkoutData())
        default:
            return .open
        }
    }
}

extension TrainingRunGoalData {
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
            type: TrainingRunType(rawValue: cache.type ?? "none") ?? .none,
            workout: WorkoutGoalData.fromCache(cache),
            progress: TrainingGoalProgressData(
                completed: cache.progressCompleted,
                activity: cache.progressActivity
            )
        )
    }
}
