//
// Created by Tobin Palmer on 7/16/23.
//

import Foundation
import FirebaseAuth

public struct AuthUtils {
    public static func initAuth() {
        if (Auth.auth().currentUser !== nil) {
            NavigationModel.instance.currentView = .HOME
        }

        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print(user)
                NavigationModel.instance.currentView = .HOME
                //go to home
            } else {
                //go to login
            }
        }
    }

    public static func loginWithEmail(_ email: String, _ password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let user = user {
                print(user)
                NavigationModel.instance.currentView = .HOME
            } else {
                print("Error logging in: \(String(describing: error))")
            }
        }
    }

    public static func logout() {
        do {
            try Auth.auth().signOut()
            NavigationModel.instance.currentView = .LOGIN
        } catch {
            print("Error logging out: \(error)")
        }
    }
}
