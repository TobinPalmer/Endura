import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

@MainActor public final class ActiveUserModel: ObservableObject {
    private let uid = AuthUtils.getCurrentUID()
    @Published public var data: ActiveUserData?

    @Published public var settings: SettingsModel {
        didSet {
            updateSettings()
        }
    }

    public var info: UserTrainingData?

    public init() {
        settings = SettingsModel(
            notifications: true
        )

        if let cachedSettings = CacheUtils.fetchObject(SettingsCache.self) {
            settings = SettingsModel.fromCache(cachedSettings)
        }

        if let cachedUserData = CacheUtils.fetchObject(ActiveUserDataCache.self) {
            data = ActiveUserData.fromCache(cachedUserData)
        }
    }

    private func updateSettings() {
        CacheUtils.updateObject(SettingsCache.self, update: settings.updateCache)
//        do {
//            try Firestore.firestore().collection("users").document(uid).collection("data").document("settings").setData(from: settings)
//        } catch {
//            print("Error updating settings: \(error)")
//        }
    }

    private final func getUserData() {
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }

            do {
                let document = try document.data(as: UserDocument.self)
                self.data = ActiveUserData(
                    uid: self.uid,
                    firstName: document.firstName,
                    lastName: document.lastName,
                    profileImage: nil,
                    friends: document.friends,
                    role: document.role
                )
            } catch {
                print("Error decoding settings: \(error)")
            }
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
            role: document.role,
            lastNotificationsRead: document.lastNotificationsRead
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
