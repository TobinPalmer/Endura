//
// Created by Brandon Kirbyson on 8/2/23.
//

import Foundation
import SwiftUI

struct UserProfileLink<Content: View>: View {
    private let uid: String
    private let content: Content

    init(_ uid: String, @ViewBuilder content: () -> Content) {
        self.uid = uid
        self.content = content()
    }

    var body: some View {
        NavigationLink(destination: UserProfileView(uid)) {
            content
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct UserProfileView: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel
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
            } else {
                Text("Loading...")
            }
        }
    }
}
