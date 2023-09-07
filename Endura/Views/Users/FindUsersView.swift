import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUI

private final class FindUsersViewModel: ObservableObject {
    @Published public var users: [(String, UserData)] = []
    @Published public var searchText = ""

    fileprivate func fetchUsers(usersCache _: UsersCacheModel) async {
        if !users.isEmpty {
            return
        }
        print("Fetching users, searchText: \(searchText)")
        let query = Firestore.firestore().collection("users").whereField("firstName", isGreaterThanOrEqualTo: searchText).whereField("firstName", isLessThanOrEqualTo: searchText + "\u{f8ff}").order(by: "firstName").limit(to: 10)

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
                    userData.profileImage = await userData.fetchProfileImage()
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

            TextField("Search", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onReceive(
                    viewModel.$searchText
                        .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
                ) {
                    viewModel.users = []
                    Task {
                        await viewModel.fetchUsers(usersCache: usersCache)
                    }
                    guard !$0.isEmpty else {
                        return
                    }
                }

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
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        }
        .task {
            await viewModel.fetchUsers(usersCache: usersCache)
        }
    }
}
