import Foundation
import SwiftUICalendar

@MainActor public final class TrainingModel: ObservableObject {
    private var saveTrainingWork: DispatchWorkItem?
    private var fetched: [YearMonth] = []

    @Published public var monthlyTrainingData: [YearMonth: MonthlyTrainingData] = [:] {
        didSet {
            for (date, data) in monthlyTrainingData {
                CacheUtils.updateListedObject(
                    MonthlyTrainingCache.self,
                    update: data.updateCache,
                    predicate: CacheUtils.predicateMatchingField("date", value: date.toCache())
                )
            }
            saveTrainingWork?.cancel()
            saveTrainingWork = DispatchWorkItem {
                for (month, data) in self.monthlyTrainingData {
                    if !self.fetched.contains(month) {
                        self.fetched.append(month)
                        self.loadTrainingMonth(month)
                    }
                }
            }
            if let saveSettingsWork = saveTrainingWork {
                DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: saveSettingsWork)
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

        loadTrainingMonth(.current)

//        var today = getTrainingDay(.current)
//        today.goals = [TrainingGoalData.run(
//            data: RunningTrainingGoalData(
//                type: .normal,
//                distance: 2.5,
//                pace: 8,
//                time: 45,
//                progress: TrainingGoalProgressData(completed: true, activity: nil)
//            )
//        )]
//        setTrainingDay(.current, today)
//        saveTrainingMonth(.current)

//        monthlyTrainingData[.current] = MonthlyTrainingData(date: .current, totalDistance: 0, totalDuration: 0, days:
//        [
//            .current: DailyTrainingData(date: .current, type: .long, goals: [TrainingGoalData.routine(
//                type: .warmup,
//                difficulty: .easy,
//                time: 4,
//                count: 5
//            ),
//                .run(type: .normal,
//                    distance: 5.03,
//                    pace: 7,
//                    time: 32),
//                .routine(type: .postrun,
//                    difficulty: .easy,
//                    time: 8,
//                    count: 10)]),
//            .current.addDay(value: -6): DailyTrainingData(date: .current.addDay(value: -6), type: .workout, goals: []),
//            .current.addDay(value: -5): DailyTrainingData(date: .current.addDay(value: -5), type: .easy, goals: [TrainingGoalData.run(
//                type: .normal,
//                distance: 5.03,
//                pace: 7,
//                time: 32
//            )]),
//        ])
    }

    public func moveGoal(_ date: YearMonthDay, _ indices: IndexSet, _ newOffset: Int) {
        var trainingDay = getTrainingDay(date)
        trainingDay.goals.move(fromOffsets: indices, toOffset: newOffset)
        setTrainingDay(date, trainingDay)
    }

    public func loadTrainingMonth(_ date: YearMonth) {
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
                            self.monthlyTrainingData[date] = MonthlyTrainingData(
                                date: date,
                                totalDistance: 0,
                                totalDuration: 0,
                                days: [:]
                            )
                        }
                        self.fetched.append(date)
                    }
                }
            }
        }
    }

    public func saveTrainingMonth(_ date: YearMonth) {
        if let data = monthlyTrainingData[date] {
            TrainingUtils.saveTrainingMonthData(data)
        }
    }

    public func getTrainingDay(_ date: YearMonthDay) -> DailyTrainingData {
        monthlyTrainingData[date.getYearMonth()]?.days[date] ?? DailyTrainingData(date: date, type: .none)
    }

    public func getTrainingDay(_ date: WeekDay) -> DailyTrainingData {
        getTrainingDay(date.toYearMonthDay())
    }

    private func setTrainingDay(_ date: YearMonthDay, _ data: DailyTrainingData) {
        var monthTrainingData = monthlyTrainingData[date.getYearMonth()] ?? MonthlyTrainingData(
            date: date.getYearMonth()
        )
        monthTrainingData.days[date] = data
        monthlyTrainingData[date.getYearMonth()] = monthTrainingData
    }

    public func updateTrainingGoal(_ date: YearMonthDay, _ goal: TrainingGoalData) {
        var trainingDay = getTrainingDay(date)
        if let index = trainingDay.goals.firstIndex(where: { $0.getUUID() == goal.getUUID() }) {
            trainingDay.goals[index] = goal
        } else {
            trainingDay.goals.append(goal)
        }
        setTrainingDay(date, trainingDay)
    }

    public func processNewActivity(_ activity: ActivityDataWithRoute) {
        updateSummaryData(for: activity.time.toYearMonthDay(), with: activity)

        var trainingDay = getTrainingDay(activity.time.toYearMonthDay())
        trainingDay.goals = TrainingUtils.updateTrainingGoals(trainingDay.goals, activity)
    }

    public func updateSummaryData(for date: YearMonthDay, with activity: ActivityDataWithRoute) {
        var trainingDay = getTrainingDay(date)
        trainingDay.summary.distance += activity.distance
        trainingDay.summary.duration += activity.duration
        trainingDay.summary.activities += 1
        setTrainingDay(date, trainingDay)

        monthlyTrainingData[date.getYearMonth()]?.totalDistance += activity.distance
        monthlyTrainingData[date.getYearMonth()]?.totalDuration += activity.duration

        saveTrainingMonth(date.getYearMonth())
    }
}
