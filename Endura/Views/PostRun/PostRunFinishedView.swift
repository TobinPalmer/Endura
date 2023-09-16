import Foundation
import SwiftUI

private final class PostRunFinishedViewModel: ObservableObject {}

struct PostRunFinishedView: View {
    @StateObject private var viewModel = PostRunFinishedViewModel()

    public var body: some View {
        VStack {
            Text("Post Run Finished View")
        }
    }
}
