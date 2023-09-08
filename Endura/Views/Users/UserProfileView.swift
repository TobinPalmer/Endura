import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUI

struct UserProfileLink<Content: View>: View {
  private let uid: String
  private let content: Content
  private let noLink: Bool

  init(_ uid: String, noLink: Bool = false, @ViewBuilder content: () -> Content) {
    self.uid = uid
    self.content = content()
    self.noLink = noLink
  }

  var body: some View {
    if noLink {
      content
    } else {
      NavigationLink(destination: UserProfileView(uid)) {
        content
      }
        .buttonStyle(PlainButtonStyle())
    }
  }
}

private final class UserProfileViewModel: ObservableObject {
  fileprivate final func addFriend(uid: String, activeUid: String) async {
    do {
      try await Firestore.firestore().collection("users").document(activeUid).updateData([
        "friends": FieldValue.arrayUnion([uid]),
      ])
      try await Firestore.firestore().collection("users").document(uid).updateData([
        "friends": FieldValue.arrayUnion([activeUid]),
      ])
    } catch {
      Global.log.error("Error updating friends: \(error)")
    }
  }
}

struct UserProfileView: View {
  @EnvironmentObject var databaseCache: UsersCacheModel
  @EnvironmentObject var activeUser: ActiveUserModel
  @StateObject private var viewModel = UserProfileViewModel()
  private let uid: String

  init(_ uid: String) {
    self.uid = uid
  }

  var body: some View {
    VStack {
      ProfileImage(uid, size: 128)
      if let user = databaseCache.getUserData(uid) {
        Text(user.name)
          .font(.title)

        if let activeUser = activeUser.data {
          if activeUser.friends.contains(uid) {
            Text("Friends")
          } else {
            Button("Add Friend") {
              Task {
                NotificationsModel.sendNotification(to: uid, data: NotificationData(type: .friendRequest, uid: activeUser.uid, timestamp: Date()))
              }
            }
          }
        }
      } else {
        Text("Loading...")
      }
    }
  }
}
