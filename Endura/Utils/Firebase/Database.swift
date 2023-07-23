////
//// Created by Tobin Palmer on 7/17/23.
////
//
//import Foundation
//import FirebaseFirestore
//import FirebaseFirestoreSwift
//
//public final class Database {
//    public class var instance: Database {
//        struct Singleton {
//            static let instance = Database()
//        }
//
//        return Singleton.instance
//    }
//
//    private init() {}
//
//    public func getUserData(userId: String) async throws -> UserData? {
//        try await withCheckedThrowingContinuation { continuation in
//            Firestore.firestore().collection("users").document(userId).getDocument(as: UserDocument.self) { (result) in
//                switch result {
//                case .success(let document):
//                    print("Successfully decoded user: \(document)")
//                    continuation.resume(returning: UserData(
//                        id: userId,
//                        name: "\(document.firstName) \(document.lastName)",
//                        firstName: document.firstName,
//                        lastName: document.lastName,
//                        profilePicture: "",
//                        friends: document.friends
//                    ))
//                case .failure(let error):
//                    print("Error decoding user: \(error)")
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//
//}
