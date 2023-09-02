import Foundation
import SwiftUI

private final class ActivityCommentModel: ObservableObject {
    @Published var commentTime: String = ""

    func getCommentTime(_ time: Date) -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        var commentTime: String
        if calendar.isDateInToday(time) {
            dateFormatter.dateFormat = "h:mm a"
            commentTime = dateFormatter.string(from: time)
        } else {
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
            commentTime = dateFormatter.string(from: time)
        }
        return commentTime
    }
}

struct ActivityComment: View {
    @StateObject private var viewModel = ActivityCommentModel()
    @EnvironmentObject var databaseCache: UsersCacheModel

    private var comment: ActivityCommentData

    init(_ comment: ActivityCommentData) {
        self.comment = comment
    }

    var body: some View {
        HStack {
            UserProfileLink(comment.uid) {
                ProfileImage(comment.uid, size: 40)
            }
            VStack(alignment: .leading) {
                if let user = databaseCache.getUserData(comment.uid) {
                    HStack {
                        UserProfileLink(comment.uid) {
                            Text(user.name)
                                .font(.title3)
                        }
                        Spacer()
                        UserProfileLink(comment.uid) {
                            Text(viewModel.getCommentTime(comment.time))
                                .font(.system(size: 12))
                        }
                    }
                } else {
                    Text("Loading...")
                }
                Text(comment.message)
            }
        }
    }
}
