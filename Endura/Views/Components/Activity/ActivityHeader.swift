//
// Created by Tobin Palmer on 8/15/23.
//

import Foundation

import SwiftUI

struct ActivityHeader: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel
    private let uid: String
    private let activityData: ActivityData
    private let bottomSpace: Bool

    public init(uid: String, activityData: ActivityData, bottomSpace: Bool = false) {
        self.uid = uid
        self.activityData = activityData
        self.bottomSpace = bottomSpace
    }

    public var body: some View {
        UserProfileLink(uid) {
            HStack {
                ProfileImage(uid, size: 50)
                if let user = databaseCache.getUserData(uid) {
                    VStack(spacing: 3) {
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                        Text("\(activityData.time.formatted()) • Santa Monica, USA")
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

        if bottomSpace {
            Spacer(minLength: 20)
        }
    }
}
