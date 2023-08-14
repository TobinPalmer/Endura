//
// Created by Tobin Palmer on 7/16/23.
//

import FirebaseAuth
import Foundation

public enum AuthUtils {
    public static func getCurrentUID() -> String {
        Auth.auth().currentUser!.uid
    }

    public static func initAuth() {
        if Auth.auth().currentUser !== nil {
            NavigationModel.instance.currentView = .HOME
        }

        Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                print(user)
                NavigationModel.instance.currentView = .HOME
            }
        }
    }

    public static func loginWithEmail(_ email: String, _ password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let user = user {
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
