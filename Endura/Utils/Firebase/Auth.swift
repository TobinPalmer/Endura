import FirebaseAuth
import FirebaseFirestore
import Foundation

public enum AuthUtils {
    public static func getCurrentUID() -> String {
        Auth.auth().currentUser!.uid
    }

    public static func createUser(email: String, password: String, userData: UserDocument, userTrainingData: UserTrainingData) {
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil, let user = user?.user {
                let uid = user.uid
                do {
                    try Firestore.firestore().collection("users").document(uid).setData(from: userData)
                    try Firestore.firestore().collection("users").document(uid).collection("data").document("info").setData(from: userTrainingData)
                    try Firestore.firestore().collection("users").document(uid).collection("data").document("settings").setData(from: SettingsModel())
                } catch {
                    print("Error creating user: \(error)")
                }
                print("User created successfully")
            } else {
                print("Error creating user: \(String(describing: error))")
            }
        }
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
            if user != nil {
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
