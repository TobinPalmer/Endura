import Foundation
import SwiftUI

struct ActivityLikesList: View {
    private let likes: [String]
    private let noLink: Bool
    private var number: CGFloat = 25
    private var shadow: CGFloat = -1

    public init(_ likes: [String], noLink: Bool = false, reverse: Bool = false) {
        self.likes = likes
        self.noLink = noLink
        if reverse {
            number = -25
            shadow = 1
        }
    }

    public var body: some View {
        ZStack {
            ForEach(0 ..< likes.prefix(3).count, id: \.self) { i in
                UserProfileLink(likes[i], noLink: noLink) {
                    ProfileImage(likes[i], size: 30)
                        .offset(x: CGFloat(i) * number, y: 0)
                        .shadow(radius: 1, x: shadow, y: 0)
                }
            }
        }
    }
}
