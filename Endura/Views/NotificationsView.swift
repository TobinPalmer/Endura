import Foundation
import SwiftUI

private enum NotificationsActionsUtils {
    fileprivate static func acceptFriendRequest(_ uid: String) {
        NotificationsModel.sendNotification(
            to: uid,
            data: NotificationData(type: .friendRequestAccepted, uid: AuthUtils.getCurrentUID(), timestamp: Date())
        )
    }
}

struct NotificationsView: View {
    @EnvironmentObject var notificationsModel: NotificationsModel

    public var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            VStack {
                Text("Notifications")
                ScrollView {
                    LazyVStack {
                        ForEach(notificationsModel.notifications, id: \.timestamp) { notification in
                            NotificationRow(notification)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
}

struct NotificationRow: View {
    @EnvironmentObject var databaseCache: UsersCacheModel
    private let notification: NotificationData

    init(_ notification: NotificationData) {
        self.notification = notification
    }

    public var body: some View {
        VStack {
            switch notification.type {
            case .friendRequest:
                if let user = databaseCache.getUserData(notification.uid) {
                    HStack {
                        UserProfileLink(notification.uid) {
                            ProfileImage(notification.uid, size: 48)
                        }
                        VStack {
                            Text(user.name)
                            Text("Friend Request")
                        }
                        Spacer()
                        Button("Accept") {
                            NotificationsActionsUtils.acceptFriendRequest(notification.uid)
                        }
                        .buttonStyle(EnduraButtonStyleOld())
                    }
                }
            case .friendRequestAccepted:
                if let user = databaseCache.getUserData(notification.uid) {
                    UserProfileLink(notification.uid) {
                        HStack {
                            ProfileImage(notification.uid)
                            VStack {
                                Text(user.name)
                                Text("Accepted Friend Request")
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(10)
    }
}
