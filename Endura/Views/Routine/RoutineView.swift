import Foundation
import SwiftUI

private var postRunEasyDay: [RoutineExercise] = [
    RoutineExercise(.frontPlank, 3),
    RoutineExercise(.pushups, 10),
    RoutineExercise(.squats, 10),
    RoutineExercise(.forwardLunge, 10),
]

private final class RoutineViewModel: ObservableObject {
    private var currentExerciseIndex: Int = 0
    @Published fileprivate private(set) var currentExercise: RoutineExercise

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

private final class RoutineExerciseViewModel: ObservableObject {
    @Published public var exercise: RoutineExercise
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
                    guard self != nil else {
                        return
                    }

//          self.exercise.parameter = .count(10)
                }
                timer.invalidate()
            }
        }
    }

    init(exercise: RoutineExercise) {
        self.exercise = exercise
    }
}

struct RoutineExerciseView: View {
    @ObservedObject private var viewModel: RoutineExerciseViewModel
    @Binding private var currentStep: Int
    @State private var finished: Bool = false

    fileprivate init(viewModel: RoutineExerciseViewModel, currentStep: Binding<Int>) {
        _viewModel = ObservedObject(initialValue: viewModel)
        _currentStep = currentStep
    }

    public var body: some View {
        if let exerciseReference = routineExerciseReference[viewModel.exercise.type] {
            VStack(spacing: 20) {
                Text("Step \(currentStep + 1) of \(postRunEasyDay.count)")
                if finished {
                    Text("FINISHED GG")
                } else {
                    Spacer()
                        .frame(height: 50)

                    Text(exerciseReference.name)
                        .font(.title)
                        .padding()

                    Spacer()
                        .frame(height: 50)

                    switch exerciseReference.amountType {
                    case .distance:
                        Text("Do \(exerciseReference.name) for \(viewModel.exercise.amount) meters")
                        Spacer()

                        HStack {
                            Button("Next") {
                                withAnimation {
                                    if currentStep == postRunEasyDay.count {
                                        finished = true
                                    } else {
                                        currentStep += 1
                                    }
                                }
                            }
                            .buttonStyle(EnduraNewButtonStyle(backgroundColor: .accentColor))
                        }
                    case .count:
                        Text("Do \(viewModel.exercise.amount) \(exerciseReference.name)")
                        Spacer()

                        HStack {
                            Button("Next") {
                                withAnimation {
                                    if currentStep == postRunEasyDay.count {
                                        finished = true
                                    } else {
                                        currentStep += 1
                                    }
                                }
                            }
                            .buttonStyle(EnduraNewButtonStyle(backgroundColor: .accentColor))
                        }
                    case .time:
                        Text("Do \(viewModel.exercise.amount) seconds of \(exerciseReference.name)")
                        PostRunTimerRing(
                            time: $viewModel.currentTime,
                            duration: Double(viewModel.exercise.amount),
                            size: 150
                        )
                        .environmentObject(viewModel)
                        .padding(.bottom, 20)

                        Spacer()

                        if viewModel.currentTime > 0 {
                            HStack {
                                Button("Next") {
                                    withAnimation {
                                        if currentStep == postRunEasyDay.count {
                                            finished = true
                                        } else {
                                            currentStep += 1
                                        }
                                    }
                                }
                                .buttonStyle(EnduraNewButtonStyle(backgroundColor: viewModel
                                        .currentTime >= Double(viewModel.exercise.amount) ? .accentColor : .gray))
                                .disabled(viewModel.currentTime < Double(viewModel.exercise.amount))
                            }
                        } else {
                            HStack {
                                Button("Start Time") {
                                    viewModel.startTimer(duration: Double(viewModel.exercise.amount))
                                }
                                .buttonStyle(EnduraNewButtonStyle(backgroundColor: .accentColor))
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding()
        }
    }
}

struct PostRunView: View {
    @StateObject private var viewModel = RoutineViewModel()
    @State private var currentPage = 0

    public var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            var views: [AnyView] = postRunEasyDay.map { exercise in
                AnyView(RoutineExerciseView(
                    viewModel: RoutineExerciseViewModel(exercise: exercise),
                    currentStep: $currentPage
                ))
            }
            let _ = views.append(AnyView(Text("FINISHED")))

            MultiStepForm(views, viewModel: RoutineViewModel(), currentPage: $currentPage)
        }
    }
}
