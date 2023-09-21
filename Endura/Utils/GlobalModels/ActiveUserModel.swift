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

    @Published public var settings: SettingsModel

    @Published public var training: TrainingModel

    public init() async throws {
        settings = try await SettingsModel()

        training = try await TrainingModel()

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
                Global.log.error("Error fetching user data: \(error)")
            }
        }
    }
}
