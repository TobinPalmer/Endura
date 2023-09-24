import Foundation
import SwiftUI

private var postRunEasyDay: [PostRunExercise] = [
    PostRunExercise(type: .plank, parameter: .time(10)),
    PostRunExercise(type: .pushup, parameter: .count(10)),
    PostRunExercise(type: .squat, parameter: .count(10)),
    PostRunExercise(type: .lunge, parameter: .count(10)),
]

// final class PostRunViewModel: ObservableObject {
//  @Published public var currentTime: TimeInterval = 0
//  @Published public var isDoneWithTimerExercise = false
//  @Published fileprivate var currentExerciseIndex: Int = 0
//  fileprivate let numberOfExercises = postRunEasyDay.count
//
//  public final var timer: Timer?
//
//  public func startTimer(duration: TimeInterval) {
//    currentTime = 1
//
//    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//      guard let self = self else {
//        return
//      }
//
//      self.currentTime += 1
//
//      if self.currentTime >= duration {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//          guard let self = self else {
//            return
//          }
//
//          isDoneWithTimerExercise = true
//        }
//        timer.invalidate()
//      }
//    }
//  }
// }

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
        VStack {
            Text(String(describing: viewModel.exercise.type))

            Button("Next") {
                withAnimation {
                    currentStep += 1
                }
            }
            .buttonStyle(EnduraButtonStyle(backgroundColor: .accentColor))

            Button("Back") {
                withAnimation {
                    currentStep -= 1
                }
            }
            .disabled(currentStep == 0)
            .buttonStyle(EnduraButtonStyle(backgroundColor: currentStep == 0 ? .gray : .accentColor))
        }
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
                AnyView(PostRunExerciseView(viewModel: PostRunExerciseViewModel(exercise: exercise), currentStep: $currentPage))
            }

            MultiStepForm(views, viewModel: SignupFormInfo(), currentPage: $currentPage)
        }
    }

//    public var body: some View {
//        ZStack {
//            Color.white
//                .ignoresSafeArea()
//
//            VStack {
//                let currentExercise = postRunEasyDay[viewModel.currentExerciseIndex]
//                Text("\(String(describing: currentExercise.type)) for \(String(describing: currentExercise.parameter))")
//                switch currentExercise.parameter {
//                case let .count(count):
//                    FormBarView(progress: $viewModel.currentExerciseIndex, steps: viewModel.numberOfExercises)
//                        .frame(width: 300, height: 50)
//
//                    Text("Do \(count)")
//                case .time:
//                    FormBarView(progress: $viewModel.currentExerciseIndex, steps: viewModel.numberOfExercises)
//                        .frame(width: 300, height: 50)
//
//                    PostRunTimerRing(time: $viewModel.currentTime, duration: 10, size: 150)
//                        .environmentObject(viewModel)
//                }
//
//                if let exerciseInfo = postRunExerciseReference[currentExercise.type] {
//                    Text(exerciseInfo.name)
//                        .font(.title)
//                        .padding()
//                    Text(exerciseInfo.description)
//                        .padding()
//                }
//                Spacer()
//
//                VStack {
//                    if viewModel.currentExerciseIndex == viewModel.numberOfExercises - 1 {
//                        Button {
//                            isFinished = true
//                        } label: {
//                            Text("Done")
//                                .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(EnduraButtonStyle())
//                    } else {
//                        switch currentExercise.parameter {
//                        case .count:
//                            Button {
//                                viewModel.currentExerciseIndex += 1
//                                viewModel.isDoneWithTimerExercise = false
//                            } label: {
//                                Text("Next")
//                                    .frame(maxWidth: .infinity)
//                            }
//                            .buttonStyle(EnduraButtonStyle())
//
//                        case .time:
//                            if viewModel.currentTime > 0 {
//                                Button {
//                                    viewModel.currentTime = 0
//                                    viewModel.timer?.invalidate()
//                                } label: {
//                                    Text("Cancel")
//                                        .frame(maxWidth: .infinity)
//                                }
//                                .buttonStyle(EnduraButtonStyle())
//
//                                Button {
//                                    viewModel.currentExerciseIndex += 1
//                                    viewModel.isDoneWithTimerExercise = false
//                                } label: {
//                                    Text("Next")
//                                        .frame(maxWidth: .infinity)
//                                }
//                                .disabled(!viewModel.isDoneWithTimerExercise)
//                                .buttonStyle(EnduraButtonStyle(disabled: !viewModel.isDoneWithTimerExercise))
//                            }
//                        }
//                    }
//
//                    if viewModel.currentTime <= 0 {
//                        Button {
//                            viewModel.startTimer(duration: 10)
//                        } label: {
//                            Text("Start")
//                                .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(EnduraButtonStyle())
//                        .frame(maxWidth: .infinity)
//                    }
//                }
//                .padding()
//                .fullScreenCover(isPresented: $isFinished) {
//                    PostRunFinishedView()
//                }
//            }
//            .frame(
//                maxWidth: .infinity,
//                maxHeight: .infinity,
//                alignment: .center
//            )
//        }
//    }
}
