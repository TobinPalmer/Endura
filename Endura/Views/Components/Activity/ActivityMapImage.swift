import CachedAsyncImage
import Foundation
import SwiftUI

struct ActivityMapImage: View {
    private let id: String

    init(_ id: String) {
        self.id = id
    }

    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/runningapp-6ee99.appspot.com/o/activities%2F\(id)%2Fmap?alt=media")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}
