import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public final class SettingsModel: ObservableObject {
    private var saveSettingsWork: DispatchWorkItem?
    private var fetched = false

    @Published public var data: SettingsDataModel! {
        didSet {
            CacheUtils.updateObject(SettingsCache.self, update: data.updateCache)
            saveSettingsWork?.cancel()
            saveSettingsWork = DispatchWorkItem {
                if self.data != nil && self.fetched {
                    self.saveSettings()
                }
            }
            if let saveSettingsWork = saveSettingsWork {
                DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: saveSettingsWork)
            }
        }
    }

    init() async throws {
        if let cachedSettings = CacheUtils.fetchObject(SettingsCache.self) {
            data = SettingsDataModel.fromCache(cachedSettings)
            fetchSettings { settings in
                self.data = settings
                self.fetched = true
            }
        } else {
            data = try await fetchSettings()
            fetched = true
        }
    }

    private func fetchSettings() async throws -> SettingsDataModel? {
        let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID())
            .collection("data").document("settings").getDocument()
        return document.exists ? try document.data(as: SettingsDataModel.self) : nil
    }

    private func fetchSettings(_ completion: @escaping (SettingsDataModel) -> Void) {
        Task {
            do {
                if let data = try await self.fetchSettings() {
                    DispatchQueue.main.async {
                        completion(data)
                    }
                } else {
                    self.fetched = true
                    DispatchQueue.main.async {
                        completion(SettingsDataModel.getDefault())
                    }
                }
            } catch {
                Global.log.error("Error fetching settings: \(error)")
            }
        }
    }

    private func saveSettings() {
        do {
            try Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID())
                .collection("data").document("settings").setData(from: data)
        } catch {
            Global.log.error("Error saving settings: \(error)")
        }
    }
}
