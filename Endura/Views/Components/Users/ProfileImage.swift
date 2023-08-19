//
// Created by Brandon Kirbyson on 8/1/23.
//

import Foundation
import SwiftUI

struct ProfileImage: View {
    @EnvironmentObject var databaseCache: DatabaseCacheModel

    private let uid: String
    private let size: Double
    private let placeholder: Bool

    init(_ uid: String, size: Double = 32, placeholder: Bool = false) {
        self.uid = uid
        self.size = size
        self.placeholder = placeholder
    }

    var body: some View {
        if placeholder {
            Image(systemName: "person.crop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: size, height: size)
        } else {
            if let user = databaseCache.getUserData(uid) {
                if let profileImage = user.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .frame(width: size, height: size)
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .frame(width: 128, height: 128)
                }
            } else {
                Text("Loading...")
            }
        }
    }
}
