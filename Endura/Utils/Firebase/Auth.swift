//
// Created by Tobin Palmer on 7/16/23.
//

import Foundation
import FirebaseAuth

struct AuthUtils {
    private var currentUser: User? {
        get {
            Auth.auth().currentUser
        }
    }

    public static func initAuth() {
        if (Auth.auth().currentUser !== nil) {
            //go to home
//            NavigationUtils.goToHome()
        }
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print(user)
                //go to home
            } else {
                //go to login
            }
        }
    }

    public static func loginWithEmail(_ email: String, _ password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let user = user {
                // Redirect to home page
            } else {
                print("Error logging in: \(String(describing: error))")
            }
        }
    }
}
