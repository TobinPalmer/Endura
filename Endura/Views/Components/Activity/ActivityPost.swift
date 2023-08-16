//
// Created by Brandon Kirbyson on 7/21/23.
//

import Foundation
import SwiftUI

struct ActivityPost: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel
    private var activity: ActivityData
    private var id: String

    @State var message: String = ""

    init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    var body: some View {
        VStack(spacing: 14) {
            ActivityHeader(uid: activity.uid)

            NavigationLink(destination: ActivityView(id: id, activity: activity)) {
                VStack(spacing: 10) {
                    Text("Afternoon Run")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Very good run today. I felt great and was able to keep a good pace throughout the run. I'm looking forward to my next run.")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            ActivityPostStats(distance: activity.distance, duration: activity.duration, pace: activity.pace)

            NavigationLink(destination: ActivityView(id: id, activity: activity)) {
                ActivityMapImage(id)
                    .cornerRadius(5)
                    .shadow(color: Color(.systemGray5), radius: 5, x: 0, y: 0)
            }

            .buttonStyle(PlainButtonStyle())

            HStack {
                Button(action: {
                    ActivityUtils.toggleLike(id: id, activity: activity)
                }) {
                    Image(systemName: "hand.thumbsup")
                        .font(.title)
                }
                ForEach(activity.likes, id: \.self) { uid in
                    UserProfileLink(uid) {
                        ProfileImage(uid, size: 30)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading) {
                ForEach(activity.comments, id: \.self) { comment in
                    ActivityComment(comment)
                }
                HStack {
                    TextField("Add a comment...", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        let comment = ActivityCommentData(uid: AuthUtils.getCurrentUID(), time: Date(), message: message)
                        message = ""
                        ActivityUtils.addComment(id: id, comment: comment)
                    }) {
                        Image(systemName: "paperplane")
                    }
                }
            }
        }
        .padding(8)
        .cornerRadius(10)
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(.systemBackground))
        .shadow(color: Color(.systemGray5), radius: 5, x: 0, y: 0)
        .cornerRadius(10)
    }
}
