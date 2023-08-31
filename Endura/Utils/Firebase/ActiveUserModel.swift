import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

@MainActor public final class ActiveUserModel: ObservableObject {
    private let uid = AuthUtils.getCurrentUID()

    @Published public var settings: SettingsModel {
        didSet {
            updateSettings()
        }
    }

    public var info: UserTrainingData

    public init(settings: SettingsModel, info: UserTrainingData) {
        self.settings = settings
        self.info = info
    }

    private func updateSettings() {
        do {
            try Firestore.firestore().collection("users").document(uid).collection("data").document("settings").setData(from: settings)
        } catch {
            print("Error updating settings: \(error)")
        }
    }

    public static func fetchSettings() async throws -> SettingsModel {
        let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("data").document("settings").getDocument(as: SettingsModel.self)
        return document
    }

    public static func fetchInfo() async throws -> UserTrainingData {
        let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).collection("data").document("training").getDocument(as: UserTrainingData.self)
        return document
    }
}
