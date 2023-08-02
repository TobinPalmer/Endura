//
// Created by Brandon Kirbyson on 7/21/23.
//

import Foundation
import SwiftUI

struct ActivityPost: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel
    private var activity: ActivityData
    private var id: String

    init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                ProfileImage(activity.uid)
                if let user = databaseCache.getUserData(activity.uid) {
                    Text(user.name)
                        .font(.title)
                } else {
                    Text("Loading...")
                }
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

            Rectangle()
                .frame(width: .infinity, height: 200)
                .foregroundColor(Color(.cyan))
                .cornerRadius(10)

            HStack {
                Button(action: {
                    ActivityUtils.toggleLike(id: id, activity: activity)
                }) {
                    Image(systemName: "hand.thumbsup")
                        .font(.title)
                }
                ForEach(activity.likes, id: \.self) { uid in
                    ProfileImage(uid)
                        .frame(width: 30, height: 30)
                }
            }
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                ForEach(activity.comments, id: \.self) { comment in
                    ActivityComment(comment)
                }
                HStack {
                    TextField("Add a comment...", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        print("Post")
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
