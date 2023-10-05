import Foundation
import SwiftUICalendar

public struct TrainingEndGoalData: Cacheable {
    public var date: YearMonthDay
    public var startDate: YearMonthDay
    public var distance: Double
    public var time: Double
    public var currentTime: Double
    public var pace: Double {
        time / distance
    }

    public var completed: Bool

    public func updateCache(_ cache: TrainingEndGoalCache) {
        cache.date = date.toCache()
        cache.startDate = startDate.toCache()
        cache.distance = distance
        cache.time = time
        cache.currentTime = currentTime
        cache.completed = completed
    }

    public static func fromCache(_ cache: TrainingEndGoalCache) -> TrainingEndGoalData {
        TrainingEndGoalData(
            date: YearMonthDay.fromCache(cache.date ?? YearMonthDay.current.toCache()),
            startDate: YearMonthDay.fromCache(cache.startDate ?? YearMonthDay.current.toCache()),
            distance: cache.distance,
            time: cache.time,
            currentTime: cache.currentTime,
            completed: cache.completed
        )
    }
}

public struct TrainingEndGoalDocument: Codable {
    public var date: String
    public var startDate: String
    public var distance: Double
    public var time: Double
    public var currentTime: Double
    public var completed: Bool

    public init(
        date: YearMonthDay,
        startDate: YearMonthDay,
        distance: Double,
        time: Double,
        currentTime: Double,
        completed: Bool
    ) {
        self.date = date.toCache()
        self.startDate = startDate.toCache()
        self.distance = distance
        self.time = time
        self.currentTime = currentTime
        self.completed = completed
    }
}
