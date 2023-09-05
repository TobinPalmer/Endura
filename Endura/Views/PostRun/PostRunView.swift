import Foundation
import SwiftUI

private final class PostRunViewModel: ObservableObject {
    @Published fileprivate var currentTime: TimeInterval = 0

    fileprivate func startTimer() {
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.currentTime += 1
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}

struct PostRunView: View {
    @StateObject private var viewModel = PostRunViewModel()

    public var body: some View {
        VStack {
            PostRunTimerRing(duration: 10, currentTime: viewModel.currentTime, lineWidth: 10, gradient: Gradient(colors: [.red, .blue]))
                .frame(width: 200, height: 200)
        }
        .onAppear {
            viewModel.startTimer()
        }
    }
}
