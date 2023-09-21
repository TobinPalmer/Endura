import FirebaseAuth
import FirebaseFirestore
import Foundation

public enum AuthUtils {
    public static func getCurrentUID() -> String {
        Auth.auth().currentUser!.uid
    }

    public static func createUser(email: String, password: String, userData: UserDocument) {
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil, let user = user?.user {
                let uid = user.uid
                do {
                    try Firestore.firestore().collection("users").document(uid).setData(from: userData)
                    let defaultSettings = SettingsDataModel(
                        notifications: true,
                        notificationsFriendRequest: true,
                        notificationsFriendRequestAccepted: true,
                        notificationsNewLike: true,
                        notificationsNewComment: true,
                        notificationsDailyTrainingPlan: true,
                        notificationsDailySummary: true,
                        notificationsFinishedActivity: true,
                        notificationsPostRunReminder: true,
                        defaultActivityVisibility: .friends
                    )
                    try Firestore.firestore().collection("users").document(uid).collection("data").document("settings").setData(from: defaultSettings)
                } catch {
                    Global.log.error("Error creating user: \(error)")
                }
            } else {
                Global.log.error("Error creating user: \(String(describing: error))")
            }
        }
    }

    #if DEBUG
        public static func generateTestUsers(_ amount: Int) {
            for i in 0 ... amount {
                let email = "test\(i)@test.com"
                let password = "testpass\(i)"
                let randomNames = ["Adam", "Bob", "Charlie", "David", "Ethan", "Frank", "George", "Henry", "Isaac", "Jack", "Kevin", "Liam", "Michael", "Noah", "Oliver", "Peter", "Quinn", "Robert", "Samuel", "Thomas", "Ulysses", "Victor", "William", "Xavier", "Yuri", "Zachary"]
                let userData = UserDocument(
                    firstName: randomNames[Int.random(in: 0 ... randomNames.count - 1)],
                    lastName: "\(randomNames[Int.random(in: 0 ... randomNames.count - 1)])",
                    friends: [],
                    role: .USER,
                    birthday: Date(),
                    gender: .OTHER,
                    email: email
                )
                createUser(email: email, password: password, userData: userData)
            }
        }
    #endif

    public static func initAuth() {
        if Auth.auth().currentUser !== nil {
            NavigationModel.instance.currentView = .HOME
        }

        Auth.auth().addStateDidChangeListener { _, user in
            if user != nil {
                NavigationModel.instance.currentView = .HOME
            }
        }
    }

    public static func loginWithEmail(_ email: String, _ password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if user != nil {
                NavigationModel.instance.currentView = .HOME
            } else {
                Global.log.error("Error logging in: \(String(describing: error))")
            }
        }
    }

    public static func logout() {
        do {
            try Auth.auth().signOut()
            PersistenceController.shared.clearAll()
            NavigationModel.instance.currentView = .LOGIN
        } catch {
            Global.log.error("Error logging out: \(error)")
        }
    }
}
