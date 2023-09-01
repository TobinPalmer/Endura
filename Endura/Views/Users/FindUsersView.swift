import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUI

private final class FindUsersViewModel: ObservableObject {
    @Published public var users: [(String, UserData)] = []

    fileprivate func fetchUsers(usersCache: UsersCacheModel) async {
        if !users.isEmpty {
            return
        }
        let query = Firestore.firestore().collection("users").order(by: "firstName").limit(to: 10)

        do {
            let querySnapshot = try await query.getDocuments()

            for document in querySnapshot.documents {
                do {
                    let data = try document.data(as: UserDocument.self)

                    let userData = await usersCache.fetchUserData(uid: document.documentID, document: data)
                    guard let userData = userData else {
                        return
                    }
                    users.append((document.documentID, userData))
                } catch {
                    print("Error decoding user: \(error)")
                }
            }
        } catch {
            print("Error fetching documents: \(error)")
        }
    }
}

struct FindUsersView: View {
    @EnvironmentObject var usersCache: UsersCacheModel
    @StateObject private var viewModel = FindUsersViewModel()

    var body: some View {
        VStack {
            Text("Find Users View")
            List(viewModel.users, id: \.0) { uid, user in
                UserProfileLink(uid) {
                    HStack {
                        ProfileImage(uid, size: 50)
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        }
        .task {
            await viewModel.fetchUsers(usersCache: usersCache)
        }
    }
}
