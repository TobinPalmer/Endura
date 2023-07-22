//
// Created by Tobin Palmer on 7/16/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

//public protocol ActiveUserData: UserData {
//    var email: String { get }
//    var birthDate: String { get }
//}

public struct UserData {
    var id: String
    var name: String
    var firstName: String
    var lastName: String
    var profilePicture: String
    var friends: [String]
}

struct UserDocument: Codable {
    var firstName: String
    var lastName: String
    var friends: [String]

    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case friends
    }
}

struct UsersUtil {
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
}
