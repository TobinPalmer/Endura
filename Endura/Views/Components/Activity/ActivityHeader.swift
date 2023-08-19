//
// Created by Tobin Palmer on 8/15/23.
//

import Foundation

import SwiftUI

struct ActivityHeader: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel
    private let uid: String
    private let activityData: ActivityData?
    private let bottomSpace: Bool
    private let placeholder: Bool

    public init(uid: String, activityData: ActivityData?, bottomSpace: Bool = false, placeholder: Bool = false) {
        self.uid = uid
        self.placeholder = placeholder
        self.activityData = activityData
        self.bottomSpace = bottomSpace
    }

    public var body: some View {
        if placeholder {
            VStack(spacing: 3) {
                HStack {
                    ProfileImage(uid, size: 50, placeholder: true)
                    HStack {
                        Text("---------")
                            .font(Font.custom("FlowBlock-Regular", size: 20, relativeTo: .title))
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                        Text("--------- - ---------")
                            .font(Font.custom("FlowBlock-Regular", size: 12, relativeTo: .title))
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: 50, alignment: .topLeading)
        } else {
            UserProfileLink(uid) {
                HStack {
                    ProfileImage(uid, size: 50)
                    if let user = databaseCache.getUserData(uid) {
                        VStack(spacing: 3) {
                            Text(user.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                            if let activityData = activityData {
                                Text("\(activityData.time.formatted()) \(activityData.startCity != "" ? "•" : "") \(activityData.startCity)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            }
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
}
