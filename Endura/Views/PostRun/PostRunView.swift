import Foundation
import SwiftUI

private var postRunEasyDay: [PostRunExercise] = [
    PostRunExercise(type: .plank, parameter: .time(10)),
    PostRunExercise(type: .pushup, parameter: .count(10)),
    PostRunExercise(type: .squat, parameter: .count(10)),
    PostRunExercise(type: .lunge, parameter: .count(10)),
]

final class PostRunViewModel: ObservableObject {
    @Published public var currentTime: TimeInterval = 0
    @Published public var isDoneWithTimerExercise = false
    @Published fileprivate var currentExerciseIndex: Int = 0

    public final var timer: Timer?

    public func startTimer(duration: TimeInterval) {
        currentTime = 1

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                return
            }

            self.currentTime += 1

            if self.currentTime >= duration {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self = self else {
                        return
                    }

                    isDoneWithTimerExercise = true
                }
                timer.invalidate()
            }
        }
    }
}

struct PostRunView: View {
    @StateObject private var viewModel = PostRunViewModel()

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
                case .time:
                    FormBarView(progress: $viewModel.currentExerciseIndex, steps: 10)
                        .frame(width: 300, height: 50)

                    PostRunTimerRing(time: $viewModel.currentTime, duration: 10, size: 150)
                        .environmentObject(viewModel)
                }

                if let exerciseInfo = postRunExerciseReference[currentExercise.type] {
                    Text(exerciseInfo.name)
                        .font(.title)
                        .padding()
                    Text(exerciseInfo.description)
                        .padding()
                }
                Spacer()

                VStack {
                    if viewModel.currentTime > 0 {
                        Button {
                            viewModel.currentTime = 0
                            viewModel.timer?.invalidate()
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(EnduraButtonStyleOld(backgroundColor: .accentColor))
                    }

                    if viewModel.currentTime > 0 {
                        Button {
                            viewModel.currentExerciseIndex += 1
                            viewModel.isDoneWithTimerExercise = false
                        } label: {
                            Text("Next")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(EnduraButtonStyleOld(backgroundColor: .accentColor))
                        .disabled(!viewModel.isDoneWithTimerExercise)
                    }

                    if viewModel.currentTime <= 0 {
                        Button {
                            viewModel.startTimer(duration: 10)
                        } label: {
                            Text("Start")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(EnduraButtonStyleOld(backgroundColor: .accentColor))
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
        }
    }
}
