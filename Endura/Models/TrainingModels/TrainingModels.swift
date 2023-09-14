import Foundation
import SwiftUICalendar

public enum TrainingGoalData: Codable, Hashable {
    case run(
        distance: Double,
        pace: Double,
        time: Double,
        difficulty: TrainingGoalDifficulty,
        runType: TrainingRunType
    )
    case postRun(
        time: Double,
        count: Int
    )
    case warmup(
        time: Double,
        count: Int
    )
}

public struct DailyTrainingData: Cacheable {
    public var date: YearMonthDay
    public var type: TrainingDayType
    public var goals: [TrainingGoalData]

    func updateCache(_ cache: DailyTrainingCache) {
        cache.date = date.toCache()
        cache.type = type.rawValue
    }

    static func fromCache(_ cache: DailyTrainingCache) -> Self {
        DailyTrainingData(
            date: YearMonthDay.fromCache(cache.date ?? ""),
            type: TrainingDayType(rawValue: cache.type ?? "none") ?? .none,
            goals: []
        )
    }
}

public struct WeeklyTrainingData {
    public var week: Date
    public var days: [Day: DailyTrainingData]
    public var dailySummary: [Day: DailySummaryData]
}

public struct UserTrainingData: Codable {
    public let weeklyTraining: [Date: String]
}
