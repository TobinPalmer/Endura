//
// Created by Brandon Kirbyson on 7/21/23.
//

import Foundation
import SwiftUI


struct ProfileImage: View {
    private var uid: String

    init(uid: String) {
        self.uid = uid
    }

    var body: some View {
        AsyncImage(url: URL(string: "https://ui-avatars.com/api/?name=\(uid)&size=256&background=0D8ABC&color=fff")) { image in
            image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
        } placeholder: {
            ProgressView()
        }
    }
}
