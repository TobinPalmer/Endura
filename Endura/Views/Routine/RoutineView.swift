import Foundation
import SwiftUI

public var postRunEasyDay: [RoutineExercise] = [
    RoutineExercise(.frontPlank, 5),
    RoutineExercise(.pushups, 10),
    RoutineExercise(.toeWalk, 20),
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

        withAnimation {
            currentTime = 1
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                return
            }

            withAnimation {
                self.currentTime += 1
            }

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
            VStack(spacing: 10) {
                Text("Step \(currentStep + 1) of \(postRunEasyDay.count)")
                    .fontColor(.muted)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                if finished {
                    Text("FINISHED GG")
                } else {
                    Text("\(exerciseReference.amountType.getAmountString(viewModel.exercise.amount))")
                        .font(.body)
                        .fontColor(.secondary)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    if exerciseReference.amountType == .time {
                        PostRunTimerRing(
                            time: $viewModel.currentTime,
                            duration: Double(viewModel.exercise.amount),
                            size: 200
                        )
                        .environmentObject(viewModel)
                        .padding(.vertical, 10)
                    } else {
                        ZStack {
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 16)
                                .frame(width: 150, height: 150)

                            VStack {
                                switch exerciseReference.amountType {
                                case .count:
                                    Text("x\(viewModel.exercise.amount)")
                                        .font(.system(size: 50, weight: .bold, design: .rounded))
                                        .foregroundColor(.accentColor)
                                case .distance:
                                    Text("\(viewModel.exercise.amount)m")
                                        .font(.system(size: 50, weight: .bold, design: .rounded))
                                        .foregroundColor(.accentColor)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }

                    Text(exerciseReference.name)
                        .font(.title)
                        .fontColor(.primary)
                        .fontWeight(.bold)

                    HStack {
                        ColoredBadge(
                            text: exerciseReference.benefit.rawValue,
                            color: exerciseReference.benefit.getColor()
                        )

//                        Image(systemName: "ruler")
//                            .fontColor(.muted)
//                            .fontWeight(.bold)

//                        ColoredBadge(text: exerciseReference.amountType.getAmountString(viewModel.exercise.amount), color: Color("EnduraGreen"))
                    }

                    Text(exerciseReference.description)
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .fontColor(.secondary)
                        .fontWeight(.bold)

                    Spacer()

                    if exerciseReference.amountType != .time {
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
                    } else {
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

struct RoutineView: View {
    @StateObject private var viewModel = RoutineViewModel()
    @State private var currentPage = 0
    public var routine: RoutineData

    public var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            var views: [AnyView] = routine.exercises.map { exercise in
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
