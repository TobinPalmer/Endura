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
            userData = try await UsersUtil.getUserData(uid: uid)
        } catch {
            print("Error getting user data: \(error)")
        }
    }
}


public final class ActiveUserModel: ObservableObject {
    @Published final var userData: UserData

    init() {
        userData = UserData(
                uid: "",
                name: "",
                firstName: "",
                lastName: "",
                profilePicture: "",
                friends: []
        )
    }

    public final func getData() async {
        if let uid = Auth.auth().currentUser?.uid {
            do {
                if let data = try await UsersUtil.getUserData(uid: uid) {
                    userData = data
                }
            } catch {
                print("Error getting active user data: \(error)")
            }
        }
    }
}


struct UsersUtil {
    private static var usersCache: [String: UserData] = [:]

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
                                uid: uid,
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
