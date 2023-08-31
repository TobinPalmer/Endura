import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUI

private final class FindUsersViewModel: ObservableObject {
    @Published public var users: [(String, UserData)] = []

    fileprivate func fetchUsers(usersCache: UsersCacheModel) async {
        users = []
        let query = Firestore.firestore().collection("users").order(by: "firstName").limit(to: 10)

        query.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }

            for document in snapshot.documents {
                do {
                    let data = try document.data(as: UserDocument.self)

                    Task {
                        let data = await usersCache.fetchUserData(uid: document.documentID, document: data)
                        guard let data = data else {
                            return
                        }
                        self.users.append((document.documentID, data))
                    }
                } catch {
                    print("Error decoding user: \(error)")
                }
            }
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
