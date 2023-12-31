import FirebaseFirestore
import Foundation
import SwiftUICalendar
import WidgetKit

@MainActor public final class TrainingModel: ObservableObject {
    private var saveTrainingWork: DispatchWorkItem?
    private var fetched: [YearMonth] = []
    private var fetchedEndGoal = false

    @Published public var monthlyTrainingData: [YearMonth: MonthlyTrainingData] = [:] {
        didSet {
            for (date, data) in monthlyTrainingData {
                CacheUtils.updateListedObject(
                    MonthlyTrainingCache.self,
                    update: data.updateCache,
                    predicate: CacheUtils.predicateMatchingField("date", value: date.toCache())
                )
            }
            updateWidgetData()
            updateNotificationData()
            if let currentMonth = monthlyTrainingData[.current] {
                var workoutsToSchedule: [YearMonthDay: WorkoutGoalData] = [:]
                for i in 0 ... 1 {
                    let date = YearMonthDay.current.addDay(value: i)
                    let goals = currentMonth.days[date]?.goals ?? []
                    for goal in goals {
                        workoutsToSchedule.updateValue(goal.workout, forKey: date)
                    }
                }
                WatchWorkoutUtils.updateWorkouts(workoutsToSchedule)
            }
//            saveTrainingWork?.cancel()
//            saveTrainingWork = DispatchWorkItem {
//                for (month, _) in self.monthlyTrainingData {
//                    if oldValue[month] != self.monthlyTrainingData[month] {
//                        if self.fetched.contains(month) {
//                            if MonthlyTrainingData(date: month) != self.monthlyTrainingData[month] {
//                                self.saveTrainingMonth(month)
//                            }
//                        } else {
//                            self.loadTrainingMonth(month)
//                        }
//                    }
//                }
//            }
//            if let saveSettingsWork = saveTrainingWork {
//                DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: saveSettingsWork)
//            }
        }
    }

    @Published public var endTrainingGoal: TrainingEndGoalData? {
        didSet {
            if let endTrainingGoal = endTrainingGoal {
                CacheUtils.updateObject(
                    TrainingEndGoalCache.self,
                    update: endTrainingGoal.updateCache
                )

                if fetchedEndGoal {
                    saveEndGoal()
                }
            }
        }
    }

    init() async throws {
        let cachedMonthlyTrainingData = CacheUtils.fetchListedObject(MonthlyTrainingCache.self)
        for cachedData in cachedMonthlyTrainingData {
            let data = MonthlyTrainingData.fromCache(cachedData)
            print("Loaded training month \(data.date) from cache")
            monthlyTrainingData.updateValue(data, forKey: data.date)
        }

        loadTrainingMonth(.current)

        let cachedEndTrainingGoal = CacheUtils.fetchObject(TrainingEndGoalCache.self)
        if let cachedData = cachedEndTrainingGoal {
            endTrainingGoal = TrainingEndGoalData.fromCache(cachedData)
        }
        fetchEndGoal { data in
            self.endTrainingGoal = data
        }
    }

    public func moveGoal(_ date: YearMonthDay, _ indices: IndexSet, _ newOffset: Int) {
        var trainingDay = getTrainingDay(date)
        trainingDay.goals.move(fromOffsets: indices, toOffset: newOffset)
        setTrainingDay(date, trainingDay)
    }

    private func fetchEndGoal(_ completion: @escaping (TrainingEndGoalData?) -> Void) {
        Task {
            do {
                let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID())
                    .collection("data").document("trainingGoal").getDocument()
                if let data = document.exists ? try document.data(as: TrainingEndGoalDocument.self) : nil {
                    DispatchQueue.main.async {
                        completion(TrainingEndGoalData(
                            date: YearMonthDay.fromCache(data.date),
                            startDate: YearMonthDay.fromCache(data.startDate),
                            distance: data.distance,
                            time: data.time,
                            currentTime: data.currentTime,
                            completed: data.completed
                        ))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
                self.fetchedEndGoal = true
            } catch {
                Global.log.error("Error fetching training end goal: \(error)")
            }
        }
    }

    private func saveEndGoal() {
        guard let endTrainingGoal = endTrainingGoal else {
            return
        }
        do {
            try Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID())
                .collection("data").document("trainingGoal").setData(from: TrainingEndGoalDocument(endTrainingGoal))
        } catch {
            Global.log.error("Error saving training end goal: \(error)")
        }
    }

    public func loadTrainingMonth(_ date: YearMonth) {
        for i in -1 ... 1 {
            let date = date.addMonth(value: i)
            if !fetched.contains(date) {
                Task {
                    let data = await TrainingUtils.getTrainingMonthData(date)
                    DispatchQueue.main.async {
                        CacheUtils.deleteListedObject(
                            MonthlyTrainingCache.self,
                            predicate: CacheUtils.predicateMatchingField("date", value: date.toCache())
                        )
                        if let data = data {
                            self.monthlyTrainingData.updateValue(data, forKey: data.date)
                        } else if self.monthlyTrainingData[date] == nil {
                            self.monthlyTrainingData.updateValue(MonthlyTrainingData(
                                date: date,
                                totalDistance: 0,
                                totalDuration: 0,
                                days: [:]
                            ), forKey: date)
                        }
                        self.fetched.append(date)
                    }
                }
            }
        }
    }

    public func saveTrainingMonth(_ date: YearMonth) {
        if let data = monthlyTrainingData[date] {
            print("Saving training month \(date)")
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
        saveTrainingMonth(date.getYearMonth())
    }

    public func updateTrainingDay(_ date: YearMonthDay, _ data: DailyTrainingData) {
        setTrainingDay(date, data)
    }

    public func updateTrainingDayType(_ date: YearMonthDay, _ type: TrainingDayType) {
        var trainingDay = getTrainingDay(date)
        trainingDay.type = type
        setTrainingDay(date, trainingDay)
    }

    public func updateTrainingGoal(_ date: YearMonthDay, _ goal: TrainingRunGoalData) {
        var trainingDay = getTrainingDay(date)
        if let index = trainingDay.goals.firstIndex(where: { $0.uuid == goal.uuid }) {
            trainingDay.goals[index] = goal
        } else {
            trainingDay.goals.append(goal)
        }
        setTrainingDay(date, trainingDay)
    }

    public func removeTrainingGoal(_ date: YearMonthDay, _ goal: TrainingRunGoalData) {
        var trainingDay = getTrainingDay(date)
        if let index = trainingDay.goals.firstIndex(where: { $0.uuid == goal.uuid }) {
            trainingDay.goals.remove(at: index)
        }
        setTrainingDay(date, trainingDay)
    }

    public func processNewActivity(_ activity: ActivityDataWithRoute) {
        let day = activity.time.toYearMonthDay()
        updateSummaryData(for: day, with: activity)

        var trainingDay = getTrainingDay(day)
        trainingDay.goals = TrainingUtils.updateTrainingGoals(trainingDay.goals, activity)
        setTrainingDay(day, trainingDay)
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

    private func updateWidgetData() {
        if let userDefaults = UserDefaults(suiteName: "group.com.endurapp.EnduraApp") {
            for day in WeekDay.eachDay() {
                let data = getTrainingDay(day.toYearMonthDay())

                userDefaults.set(data.summary.distance, forKey: "dailyDistance-\(day.rawValue)")
            }

            userDefaults.set(
                getTrainingDay(.current.addDay(value: 7)).getDocument().toJSON(),
                forKey: "trainingDay"
            )

            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func updateNotificationData() {
        NotificationUtils.clearScheduledNotifications()
        let today = getTrainingDay(.current.addDay(value: 1))
//        let message = "Today is \(today.type.rawValue.lowercased()) day, you have \(today.goals.isEmpty ? "no goals
//        today!" : "\(today.goals.count) goal\(today.goals.count == 1 ? "" : "s") to complete!")"
//        NotificationUtils.sendScheduledNotification( title: "Today's Training", body: message, date:
//        Date().addingTimeInterval(5) ) NotificationUtils.sendScheduledNotification( title: "New Like!", body: "Tobin
//        Palmer liked your 2.21 mile run!", date: Date().addingTimeInterval(10) )
    }
}
