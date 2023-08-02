//
// Created by Brandon Kirbyson on 8/1/23.
//

import Foundation
import SwiftUI

struct UserInfo: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel
    private var uid: String

    init(uid: String) {
        self.uid = uid
    }

    var body: some View {
        VStack {
            if let user = databaseCache.getUserData(uid) {
                Text(user.name)
            } else {
                Text("Loading...")
            }
        }
    }
}