import Foundation
import SwiftUICalendar

@MainActor public final class TrainingModel: ObservableObject {
    @Published public var monthlyTrainingData: [YearMonth: MonthlyTrainingData] = [:] {
        didSet {
            for (date, data) in monthlyTrainingData {
                CacheUtils.updateListedObject(MonthlyTrainingCache.self, update: data.updateCache, predicate: CacheUtils.predicateMatchingField("date", value: date.toCache()))
            }
        }
    }

    @Published private var loadedMonths: [YearMonth] = []

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

        loadMonth(.current)
    }

    public func loadMonth(_ date: YearMonth) {
        for i in -1 ... 1 {
            let date = date.addMonth(value: i)
            if !loadedMonths.contains(date) {
                loadedMonths.append(date)
                Task {
                    let data = await TrainingUtils.getTrainingMonthData(date)
                    DispatchQueue.main.async {
                        if let data = data {
                            self.monthlyTrainingData[data.date] = data
                        } else if self.monthlyTrainingData[date] == nil {
                            self.monthlyTrainingData[date] = MonthlyTrainingData(date: date, totalDistance: 0, totalDuration: 0, days: [:])
                        }
                    }
                }
            }
        }
    }

    public func getTrainingDay(_ date: YearMonthDay) -> DailyTrainingData? {
        monthlyTrainingData[date.getYearMonth()]?.days[date]
    }

    public func processNewActivity(_: ActivityDataWithRoute) {}
}
