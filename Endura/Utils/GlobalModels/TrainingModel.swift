import Foundation
import SwiftUICalendar

public final class TrainingModel: ObservableObject {
    @Published public var monthlyTrainingData: [YearMonth: MonthlyTrainingData] = [:] {
        didSet {
            for (date, data) in monthlyTrainingData {
                CacheUtils.updateListedObject(MonthlyTrainingCache.self, update: data.updateCache, predicate: CacheUtils.predicateMatchingField("date", value: date.toCache()))
            }
        }
    }

    init() async throws {
        let cachedMonthlyTrainingData = CacheUtils.fetchListedObject(MonthlyTrainingCache.self)
        for cachedData in cachedMonthlyTrainingData {
            let data = MonthlyTrainingData.fromCache(cachedData)
            monthlyTrainingData[data.date] = data
        }

        monthlyTrainingData[.current] = MonthlyTrainingData(date: .current, totalDistance: 0, totalDuration: 0, days: [
            .current: DailyTrainingData(date: .current, type: .long, goals: [TrainingGoalData.routine(
                    type: .warmup,
                    difficulty: .easy,
                    time: 4,
                    count: 5
                ),
                .run(type: .normal,
                     distance: 5.03,
                     pace: 7,
                     time: 32),
                .routine(type: .postrun,
                         difficulty: .easy,
                         time: 8,
                         count: 10)]),
            .current.addDay(value: -6): DailyTrainingData(date: .current.addDay(value: -6), type: .workout, goals: []),
            .current.addDay(value: -5): DailyTrainingData(date: .current.addDay(value: -5), type: .easy, goals: [TrainingGoalData.run(
                type: .normal,
                distance: 5.03,
                pace: 7,
                time: 32
            )]),
        ])
    }

    public func getTrainingDay(_ date: YearMonthDay) -> DailyTrainingData {
        if let data = monthlyTrainingData[date.getYearMonth()]?.days[date] {
            return data
        } else {
            return DailyTrainingData(date: date, type: .none, goals: [])
        }
    }
}
