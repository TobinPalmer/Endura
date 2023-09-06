import Foundation
import SwiftUI

private var postRunEasyDay: [PostRunExercise] = [
    PostRunExercise(type: .plank, parameter: .time(10)),
    PostRunExercise(type: .pushup, parameter: .count(10)),
    PostRunExercise(type: .squat, parameter: .count(10)),
    PostRunExercise(type: .lunge, parameter: .count(10)),
]

private final class PostRunViewModel: ObservableObject {
    @Published fileprivate var currentTime: TimeInterval = 0

    @Published fileprivate var currentExerciseIndex: Int = 0

    fileprivate final func startTimer(duration: Double) {
        currentTime += duration
    }

    fileprivate final func clearTimer() {
        currentTime = 0
    }
}

struct PostRunView: View {
    @StateObject private var viewModel = PostRunViewModel()

    public var body: some View {
        VStack {
            let currentExercise = postRunEasyDay[viewModel.currentExerciseIndex]
            Text("\(String(describing: currentExercise.type)) for \(String(describing: currentExercise.parameter))")
            Button("Increment Index") {
                viewModel.currentExerciseIndex += 1
            }
        }
        .onAppear {
            viewModel.startTimer(duration: 10)
        }
    }
}
