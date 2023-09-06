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
    @State private var isDoneWithTimerExercise = false

    public var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack {
                let currentExercise = postRunEasyDay[viewModel.currentExerciseIndex]
                Text("\(String(describing: currentExercise.type)) for \(String(describing: currentExercise.parameter))")
                switch currentExercise.parameter {
                case let .count(count):
                    Text("Do \(count)")
                case let .time(time):
                    PostRunTimerRing(duration: time, currentTime: viewModel.currentTime, lineWidth: 10, gradient: Gradient(colors: [.red, .blue]))

                    let _ = DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                        isDoneWithTimerExercise = true
                    }
                }
                Button("Next Exercise") {
                    viewModel.currentExerciseIndex += 1
                    isDoneWithTimerExercise = false
                }
                .disabled(!isDoneWithTimerExercise)

                if viewModel.currentTime <= 0 {
                    Button("Start") {
                        viewModel.startTimer(duration: 10)
                    }
                }
            }
        }
    }
}
