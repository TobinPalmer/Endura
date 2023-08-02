//
// Created by Brandon Kirbyson on 8/2/23.
//

import Foundation
import SwiftUI

struct ActivityMapImage: View {
    private let id: String

    init(_ id: String) {
        self.id = id
    }

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/runningapp-6ee99.appspot.com/o/activities%2F\(id)%2Fmap?alt=media")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure(_):
                    Text("No Map Available")
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}