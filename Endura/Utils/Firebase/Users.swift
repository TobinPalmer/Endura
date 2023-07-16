//
// Created by Tobin Palmer on 7/16/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

public protocol ActiveUserData: UserData {
    var email: String { get }
    var birthDate: String { get }
}

public protocol UserData {
    var id: String { get }
    var name: String { get }
    var firstName: String { get }
    var lastName: String { get }
    var profilePicture: String { get }
    var profilePage: String { get }
    var friends: [String] { get }
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
