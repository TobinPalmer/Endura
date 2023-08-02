//
// Created by Brandon Kirbyson on 8/2/23.
//

import Foundation
import SwiftUI

struct ActivityComment: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel
    private var comment: ActivityCommentData

    init(_ comment: ActivityCommentData) {
        self.comment = comment
    }

    var body: some View {
        HStack {
            ProfileImage(comment.uid, size: 40)
            VStack(alignment: .leading) {
                if let user = databaseCache.getUserData(comment.uid) {
                    Text(user.name)
                        .font(.title3)
                } else {
                    Text("Loading...")
                }
                Text(comment.message)
            }
        }
    }
}