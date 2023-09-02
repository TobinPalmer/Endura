import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

@MainActor public final class ActiveUserModel: ObservableObject {
    private let uid = AuthUtils.getCurrentUID()
    @Published public var data: UserData

    @Published public var settings: SettingsModel {
        didSet {
            updateSettings()
        }
    }

    public var info: UserTrainingData

    public init(settings: SettingsModel, info: UserTrainingData, data: UserData) {
        self.settings = settings
        self.info = info
        self.data = data
    }

    private func updateSettings() {
        do {
            try Firestore.firestore().collection("users").document(uid).collection("data").document("settings").setData(from: settings)
        } catch {
            print("Error updating settings: \(error)")
        }
    }

    public static func fetchUserData() async throws -> UserData {
        let document = try await Firestore.firestore().collection("users").document(AuthUtils.getCurrentUID()).getDocument(as: UserDocument.self)
        let userData = UserData(
            uid: AuthUtils.getCurrentUID(),
            name: document.firstName + " " + document.lastName,
            firstName: document.firstName,
            lastName: document.lastName,
            profileImage: nil,
            friends: document.friends,
            role: document.role
        )
        return userData
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
