import Foundation
import SwiftUI

struct ActivityLikesList: View {
    private let likes: [String]

    public init(_ likes: [String]) {
        self.likes = likes
    }

    public var body: some View {
        ZStack {
            ForEach(0 ..< likes.prefix(3).count, id: \.self) { i in
                UserProfileLink(likes[i]) {
                    ProfileImage(likes[i], size: 30)
                        .offset(x: CGFloat(i) * 20, y: 0)
                        .shadow(radius: 1, x: -1, y: 0)
                }
            }
        }
    }
}
