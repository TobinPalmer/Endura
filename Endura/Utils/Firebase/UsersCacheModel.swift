import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

@MainActor public final class UsersCacheModel: ObservableObject {
    @Published private final var usersCache: [String: UserData?] = [:]

    public func getUserData(_ uid: String) -> UserData? {
        if usersCache[uid] == nil {
            Task {
                await fetchUserData(uid: uid)
            }
        }
        return usersCache[uid] as? UserData
    }

    public func fetchUserData(uid: String, document: UserDocument? = nil) async -> UserData? {
        if usersCache[uid] != nil {
            return usersCache[uid] as? UserData
        }
        do {
            usersCache.updateValue(nil, forKey: uid)
            let document = document == nil ? try await Firestore.firestore().collection("users").document(uid).getDocument(as: UserDocument.self) : document!

            // Try loading firebase profile picture
            var image = try UIImage(data: await URLSession.shared.data(from: URL(string: "https://firebasestorage.googleapis.com/v0/b/runningapp-6ee99.appspot.com/o/users%2F\(uid)%2FprofilePicture?alt=media")!).0)
            if image == nil { // If firebase profile picture fails, load ui-avatars profile picture
                image = try UIImage(data: await URLSession.shared.data(from: URL(string: "https://ui-avatars.com/api/?name=\(document.firstName)+\(document.lastName)&background=0D8ABC&color=fff")!).0)
            }

            let userData = UserData(
                uid: uid,
                firstName: document.firstName,
                lastName: document.lastName,
                profileImage: image,
                friends: document.friends
            )
            usersCache.updateValue(userData, forKey: uid)
            return userData
        } catch {
            print("Error decoding user: \(error)")
        }
        return nil
    }
}
