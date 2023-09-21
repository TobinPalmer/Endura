import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public final class SettingsModel: ObservableObject {
    @Published public var data: SettingsDataModel! {
        didSet {
            CacheUtils.updateObject(SettingsCache.self, update: data.updateCache)
        }
    }

    init() async throws {
        if let cachedSettings = CacheUtils.fetchObject(SettingsCache.self) {
            data = SettingsDataModel.fromCache(cachedSettings)
            fetchSettings { settings in
                self.data = settings
            }
        } else {
            data = try await fetchSettings()
        }
    }

    private func fetchSettings() async throws -> SettingsDataModel {
        let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("data").document("settings").getDocument(as: SettingsDataModel.self)
        return document
    }

    private func fetchSettings(_ completion: @escaping (SettingsDataModel) -> Void) {
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
}
