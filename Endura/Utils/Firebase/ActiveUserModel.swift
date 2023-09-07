import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

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
                print("Error fetching user data: \(error)")
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
                print("Error fetching settings: \(error)")
            }
        }
    }

    public static func fetchInfo() async throws -> UserTrainingData {
        let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("data").document("training").getDocument(as: UserTrainingData.self)
        return document
    }
}
