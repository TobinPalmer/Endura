import Foundation
import SwiftUI

private final class PostRunStartViewModel: ObservableObject {}

struct PostRunStartView: View {
    @StateObject private var viewModel = PostRunStartViewModel()

    public var body: some View {
        VStack {
            Text("Post Run Starting view")
        }
    }
}
