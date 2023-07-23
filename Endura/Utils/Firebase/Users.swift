//
// Created by Tobin Palmer on 7/16/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

public final class UserDataModel: ObservableObject {
    @Published final var userData: UserData?

    public final func getData(uid: String) async {
        do {
            self.userData = try await UsersUtil.getUserData(uid: uid)
        } catch {
            print("Error getting user data: \(error)")
        }
    }
}

struct UsersUtil {
    private static var usersCache: [String: UserData] = [:]

    public static func getActiveUserData(_ user: User) {
        let docRef = Firestore.firestore().collection("users").document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                print("Document data: \(String(describing: data))")
            } else {
                print("Document does not exist")
            }
        }
    }

    public static func getUserData(uid: String) async throws -> UserData? {
        try await withCheckedThrowingContinuation { continuation in
            if let cachedUser = usersCache[uid] {
                continuation.resume(returning: cachedUser)
            } else {
                Firestore.firestore().collection("users").document(uid).getDocument(as: UserDocument.self) { (result) in
                    switch result {
                    case .success(let document):
                        print("Successfully decoded user: \(document)")
                        let userData = UserData(
                                id: uid,
                                name: "\(document.firstName) \(document.lastName)",
                                firstName: document.firstName,
                                lastName: document.lastName,
                                profilePicture: "",
                                friends: document.friends
                        )
                        usersCache.updateValue(userData, forKey: uid)
                        continuation.resume(returning: userData)
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
