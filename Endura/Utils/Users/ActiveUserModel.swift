import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUICalendar

@MainActor public final class ActiveUserModel: ObservableObject {
    private let uid = AuthUtils.getCurrentUID()
    @Published public var data: ActiveUserData! {
        didSet {
            CacheUtils.updateObject(ActiveUserDataCache.self, update: data.updateCache)
        }
    }

    @Published public var settings: SettingsModel! {
        didSet {
            CacheUtils.updateObject(SettingsCache.self, update: settings.updateCache)
        }
    }

    @Published public var monthlyTrainingData: [YearMonth: MonthlyTrainingData] = [:] {
        didSet {
            for (date, data) in monthlyTrainingData {
                CacheUtils.updateListedObject(MonthlyTrainingCache.self, update: data.updateCache, predicate: CacheUtils.predicateMatchingField("date", value: date.toCache()))
            }
        }
    }

    public init() async throws {
        if let cachedSettings = CacheUtils.fetchObject(SettingsCache.self) {
            settings = SettingsModel.fromCache(cachedSettings)
            fetchSettings { settings in
                self.settings = settings
            }
        } else {
            settings = try await fetchSettings()
        }

        if let cachedUserData = CacheUtils.fetchObject(ActiveUserDataCache.self) {
            data = ActiveUserData.fromCache(cachedUserData)
            fetchUserData { data in
                self.data = data
            }
        } else {
            data = try await fetchUserData()
        }

        let cachedMonthlyTrainingData = CacheUtils.fetchListedObject(MonthlyTrainingCache.self)
        for cachedData in cachedMonthlyTrainingData {
            let data = MonthlyTrainingData.fromCache(cachedData)
            monthlyTrainingData[data.date] = data
        }

        monthlyTrainingData[.current] = MonthlyTrainingData(date: .current, totalDistance: 0, totalDuration: 0, days: [
            .current: DailyTrainingData(date: .current, type: .long, goals: [TrainingGoalData.warmup(
                    time: 32,
                    count: 1
                ),
                .run(type: .normal,
                     distance: 5.03,
                     pace: 7,
                     time: 32),
                .postRun(type: .medium,
                         time: 32,
                         count: 1)]),
            .current.addDay(value: -6): DailyTrainingData(date: .current.addDay(value: -6), type: .workout, goals: []),
            .current.addDay(value: -5): DailyTrainingData(date: .current.addDay(value: -5), type: .easy, goals: [TrainingGoalData.run(
                type: .normal,
                distance: 5.03,
                pace: 7,
                time: 32
            )]),
        ])
    }

    private func fetchUserData() async throws -> ActiveUserData {
        let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).getDocument(as: UserDocument.self)
        let userData = ActiveUserData(
            uid: AuthUtils.getCurrentUID(),
            firstName: document.firstName,
            lastName: document.lastName,
            friends: document.friends,
            role: document.role,
            lastNotificationsRead: document.lastNotificationsRead
        )
        return userData
    }

    private func fetchUserData(_ completion: @escaping (ActiveUserData) -> Void) {
        Task {
            do {
                let data = try await self.fetchUserData()
                DispatchQueue.main.async {
                    completion(data)
                }
            } catch {
                Global.log.error("Error fetching user data: \(error)")
            }
        }
    }

    private func fetchSettings() async throws -> SettingsModel {
        let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("data").document("settings").getDocument(as: SettingsModel.self)
        return document
    }

    private func fetchSettings(_ completion: @escaping (SettingsModel) -> Void) {
        Task {
            do {
                let data = try await self.fetchSettings()
                DispatchQueue.main.async {
                    completion(data)
                }
            } catch {
                Global.log.error("Error fetching settings: \(error)")
            }
        }
    }

    public func getTrainingDay(_ date: YearMonthDay) -> DailyTrainingData {
        if let data = monthlyTrainingData[date.getYearMonth()]?.days[date] {
            return data
        } else {
            return DailyTrainingData(date: date, type: .none, goals: [])
        }
    }
}
