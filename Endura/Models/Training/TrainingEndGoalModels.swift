import Foundation
import SwiftUICalendar

public struct TrainingEndGoalData: Cacheable {
    public var date: YearMonthDay
    public var startDate: YearMonthDay
    public var distance: Double
    public var time: Double
    public var currentTime: Double
    public var pace: Double {
        distance / time
    }

    public var completed: Bool

    public func daysLeft() -> Int {
        max(Int(YearMonthDay.current.getDate().distance(to: date.getDate()) / (60 * 60 * 24)), 0)
    }

    public func getProgress() -> Double {
        YearMonthDay.current.getDate().distance(to: startDate.getDate()) / date.getDate()
            .distance(to: startDate.getDate())
    }

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
        _ data: TrainingEndGoalData
    ) {
        date = data.date.toCache()
        startDate = data.startDate.toCache()
        distance = data.distance
        time = data.time
        currentTime = data.currentTime
        completed = data.completed
    }
}
