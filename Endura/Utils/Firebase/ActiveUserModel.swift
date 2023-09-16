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

    @Published public var dailyTrainingData: [YearMonthDay: DailyTrainingData] = [:] {
        didSet {
            for (date, data) in dailyTrainingData {
                if data.type != .none {
                    CacheUtils.updateListedObject(DailyTrainingCache.self, update: data.updateCache, predicate: CacheUtils.predicateMatchingField("date", value: date.toCache()))
                }
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

        let cachedDailyTrainingData = CacheUtils.fetchListedObject(DailyTrainingCache.self)
        for cachedData in cachedDailyTrainingData {
            let data = DailyTrainingData.fromCache(cachedData)
            dailyTrainingData[data.date] = data
        }

        dailyTrainingData[.current.addDay(value: -7)] = DailyTrainingData(date: .current.addDay(value: -7), type: .long, goals: [])
        dailyTrainingData[.current.addDay(value: -6)] = DailyTrainingData(date: .current.addDay(value: -6), type: .workout, goals: [])
        dailyTrainingData[.current.addDay(value: -5)] = DailyTrainingData(date: .current.addDay(value: -5), type: .easy, goals: [TrainingGoalData.run(
            type: .normal,
            distance: 5.03,
            pace: 7,
            time: 32
        )])
        dailyTrainingData[.current.addDay(value: -4)] = DailyTrainingData(date: .current.addDay(value: -4), type: .long, goals: [])
        dailyTrainingData[.current.addDay(value: -3)] = DailyTrainingData(date: .current.addDay(value: -3), type: .workout, goals: [])
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

    public static func fetchInfo() async throws -> UserTrainingData {
        let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("data").document("training").getDocument(as: UserTrainingData.self)
        return document
    }

    public func getTrainingDay(_ date: YearMonthDay) -> DailyTrainingData {
        dailyTrainingData[date] ?? DailyTrainingData(date: date, type: .none, goals: [])
    }
}
