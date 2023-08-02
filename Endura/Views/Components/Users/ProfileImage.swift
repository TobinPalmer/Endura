//
// Created by Brandon Kirbyson on 8/1/23.
//

import Foundation
import SwiftUI

struct ProfileImage: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel
    private var uid: String

    init(_ uid: String) {
        self.uid = uid
    }

    var body: some View {
        if let user = databaseCache.getUserData(uid) {
            if let profileImage = user.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            }
        } else {
            Text("Loading...")
        }
    }
}