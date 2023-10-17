import Foundation
import SwiftUI

private var postRunEasyDay: [PostRunExercise] = [
    PostRunExercise(type: .plank, parameter: .time(3)),
    PostRunExercise(type: .pushup, parameter: .count(10)),
    PostRunExercise(type: .squat, parameter: .count(10)),
    PostRunExercise(type: .lunge, parameter: .count(10)),
]

private final class PostRunViewModel: ObservableObject {
    private var currentExerciseIndex: Int = 0
    @Published fileprivate private(set) var currentExercise: PostRunExercise

    init() {
        currentExercise = postRunEasyDay[currentExerciseIndex]
    }

    fileprivate func nextExercise() {
        if currentExerciseIndex < postRunEasyDay.count - 1 {
            currentExerciseIndex += 1
            currentExercise = postRunEasyDay[currentExerciseIndex]
        }
    }
}

private final class PostRunExerciseViewModel: ObservableObject {
    @Published public var exercise: PostRunExercise
    @Published public var currentTime: TimeInterval = 0

    public var timer: Timer?

    public func startTimer(duration: TimeInterval) {
        if timer != nil {
            timer?.invalidate()
        }

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

                    self.exercise.parameter = .count(10)
                }
                timer.invalidate()
            }
        }
    }

    init(exercise: PostRunExercise) {
        self.exercise = exercise
    }
}

struct PostRunExerciseView: View {
    @ObservedObject private var viewModel: PostRunExerciseViewModel
    @Binding private var currentStep: Int

    fileprivate init(viewModel: PostRunExerciseViewModel, currentStep: Binding<Int>) {
        _viewModel = ObservedObject(initialValue: viewModel)
        _currentStep = currentStep
    }

    public var body: some View {
        let exerciseReference = postRunExerciseReference[viewModel.exercise.type]

        VStack(spacing: 20) {
            Spacer()
                .frame(height: 50)

            Text(exerciseReference?.name ?? "")
                .font(.title)
                .padding()

            Spacer()
                .frame(height: 50)

            switch viewModel.exercise.parameter {
            case let .count(count):
                Spacer()

                HStack {
                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(EnduraNewButtonStyle(backgroundColor: .accentColor))
                }
            case let .time(time):
                PostRunTimerRing(time: $viewModel.currentTime, duration: time, size: 150)
                    .environmentObject(viewModel)
                    .padding(.bottom, 20)

                Spacer()

                if viewModel.currentTime > 0 {
                    HStack {
                        Button("Next") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .buttonStyle(EnduraNewButtonStyle(backgroundColor: .accentColor))
                    }
                } else {
                    HStack {
                        Button("Start Time") {
                            viewModel.startTimer(duration: 10)
                        }
                        .buttonStyle(EnduraNewButtonStyle(backgroundColor: .accentColor))
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
    }
}

struct PostRunView: View {
    @StateObject private var viewModel = PostRunViewModel()
    @State private var currentPage = 0

    public var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            let views: [AnyView] = postRunEasyDay.map { exercise in
                AnyView(PostRunExerciseView(
                    viewModel: PostRunExerciseViewModel(exercise: exercise),
                    currentStep: $currentPage
                ))
            }

            MultiStepForm(views, viewModel: SignupFormInfo(), currentPage: $currentPage)
        }
    }
}
