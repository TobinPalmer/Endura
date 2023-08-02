//
// Created by Brandon Kirbyson on 8/2/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor public final class DatabaseCacheModel: ObservableObject {
    @Published private final var usersCache: [String: UserData?] = [:]

    public func getUserData(_ uid: String) -> UserData? {
        if usersCache[uid] == nil {
            Task {
                await fetchUserData(uid: uid)
            }
        }
        return usersCache[uid] as? UserData
    }

    private func fetchUserData(uid: String) async {
        if let cachedUser = usersCache[uid] {
            return
        }
        do {
            usersCache.updateValue(nil, forKey: uid)
            let document = try await Firestore.firestore().collection("users").document(uid).getDocument(as: UserDocument.self)
            let userData = UserData(
                    uid: uid,
                    name: "\(document.firstName) \(document.lastName)",
                    firstName: document.firstName,
                    lastName: document.lastName,
                    profilePicture: "",
                    friends: document.friends
            )
            usersCache.updateValue(userData, forKey: uid)
        } catch {
            print("Error decoding user: \(error)")
        }
    }
}