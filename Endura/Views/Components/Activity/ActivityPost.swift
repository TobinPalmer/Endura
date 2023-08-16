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
            UserProfileLink(activity.uid) {
                HStack {
                    ProfileImage(activity.uid, size: 50)
                    if let user = databaseCache.getUserData(activity.uid) {
                        VStack(spacing: 3) {
                            Text(user.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                            Text("Today at 5:26 PM • Santa Monica, USA")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                    } else {
                        Text("Loading...")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            NavigationLink(destination: ActivityView(id: id, activity: activity)) {
                Text("Afternoon Run")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Text("\(ConversionUtils.metersToMiles(activity.distance)) mi")
                Text("\(FormattingUtils.secondsToFormattedTime(activity.duration))")
            }

            NavigationLink(destination: ActivityView(id: id, activity: activity)) {
                ActivityMapImage(id)
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
