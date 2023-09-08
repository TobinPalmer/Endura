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

    public func refreshUserData(_ uid: String) {
        if let userData = usersCache[uid] as? UserData {
            setUserData(uid, userData: userData)
        }
    }

    private func setUserData(_ uid: String, userData: UserData) {
        usersCache.updateValue(userData, forKey: uid)
        CacheUtils.updateListedObject(UserDataCache.self, update: userData.updateCache, predicate: CacheUtils.predicateMatchingField("uid", value: uid))
        if userData.profileImage == nil {
            Task {
                if let profileImage = await userData.fetchProfileImage() {
                    var userData = userData
                    userData.profileImage = profileImage
                    usersCache.updateValue(userData, forKey: uid)
                    CacheUtils.updateListedObject(UserDataCache.self, update: userData.updateCache, predicate: CacheUtils.predicateMatchingField("uid", value: uid))
                }
            }
        }
    }

    public func fetchUserData(uid: String, document: UserDocument? = nil) async {
        guard usersCache[uid] == nil else {
            return
        }
        do {
            // Try loading from cache
            let cachedUserData = CacheUtils.fetchListedObject(UserDataCache.self, predicate: CacheUtils.predicateMatchingField("uid", value: uid)).first
            if let cachedUserData = cachedUserData {
                setUserData(uid, userData: UserData.fromCache(cachedUserData))
            }

            // Load from firebase, even if cached because it might be outdated
            let document = document == nil ? try await Firestore.firestore().collection("users").document(uid).getDocument(as: UserDocument.self) : document!

            var userData = UserData(
                uid: uid,
                firstName: document.firstName,
                lastName: document.lastName,
                friends: document.friends
            )
            if let profileImage = await userData.fetchProfileImage() {
                userData.profileImage = profileImage
            } else if let profileImage = cachedUserData?.profileImage {
                userData.profileImage = UIImage(data: profileImage)
            }
            setUserData(uid, userData: userData)
        } catch {
            Global.log.error("Error decoding user: \(error)")
        }
    }
}
