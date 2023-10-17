import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUI

@MainActor private final class FindUsersViewModel: ObservableObject {
    @Published public var users: [(String, UserData)] = []
    @Published public var searchText = ""

    fileprivate func fetchUsers(usersCache _: UsersCacheModel) async {
        if !users.isEmpty {
            return
        }
        let query = Firestore.firestore().collection("users")
            .whereField("firstName", isGreaterThanOrEqualTo: searchText)
            .whereField("firstName", isLessThanOrEqualTo: searchText + "\u{f8ff}").order(by: "firstName").limit(to: 10)

        do {
            let querySnapshot = try await query.getDocuments()

            for document in querySnapshot.documents {
                do {
                    let data = try document.data(as: UserDocument.self)

                    var userData = UserData(
                        uid: document.documentID,
                        firstName: data.firstName,
                        lastName: data.lastName,
                        friends: data.friends
                    )
                    if let profileImage = await userData.fetchProfileImage() {
                        userData.profileImage = profileImage
                    }
                    if !users.contains(where: { $0.0 == document.documentID }) {
                        withAnimation {
                            users.append((document.documentID, userData))
                        }
                    }
                } catch {
                    Global.log.error("Error decoding user: \(error)")
                }
            }
        } catch {
            Global.log.error("Error fetching documents: \(error)")
        }
    }
}

struct FindUsersView: View {
    @EnvironmentObject var usersCache: UsersCacheModel
    @StateObject private var viewModel = FindUsersViewModel()

    var body: some View {
        List(viewModel.users.sorted {
            $0.1.name < $1.1.name
        }, id: \.0) { uid, user in
            UserProfileLink(uid) {
                HStack {
                    ProfileImage(uid, size: 50)
                    Text(user.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                .animation(.none)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .animation(.easeInOut)
        }
        .searchable(text: $viewModel.searchText)
        .onReceive(
            viewModel.$searchText
                .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
        ) {
            if viewModel.searchText.isEmpty {
                return
            } else {
                viewModel.users = []
                Task {
                    await viewModel.fetchUsers(usersCache: usersCache)
                }
                guard !$0.isEmpty else {
                    return
                }
            }
        }
        .task {
            await viewModel.fetchUsers(usersCache: usersCache)
        }
    }
}
