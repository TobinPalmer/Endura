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
    @Published public var done: Bool = false
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
    @EnvironmentObject private var routineViewModel: RoutineViewModel
    @ObservedObject private var viewModel: RoutineExerciseViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding private var currentStep: Int
    @State private var finished: Bool = false

    private let totalSteps: Int

    fileprivate init(viewModel: RoutineExerciseViewModel, currentStep: Binding<Int>, totalSteps: Int) {
        _viewModel = ObservedObject(initialValue: viewModel)
        _currentStep = currentStep
        self.totalSteps = totalSteps
    }

    public var body: some View {
        if let exerciseReference = routineExerciseReference[viewModel.exercise.type] {
            VStack {
                if finished {
                    VStack {
                        Text("Finished")
                            .fontColor(.muted)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        Spacer()
                        Text("Great job!")
                            .font(.title)
                            .fontColor(.primary)
                            .fontWeight(.bold)
                        Spacer()
                        Button("Done") {
                            routineViewModel.done = true
                            dismiss()
                        }
                        .buttonStyle(EnduraNewButtonStyle())
                    }
                } else {
                    VStack(spacing: 10) {
                        Text("Step \(currentStep + 1) of \(totalSteps)")
                            .fontColor(.muted)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        Spacer()
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

                        let color = exerciseReference.benefit.getColor()
                        HStack {
                            Image(systemName: exerciseReference.benefit.getIcon())
                            Text(exerciseReference.benefit.rawValue)
                        }
                        .fontWeight(.bold)
                        .foregroundColor(color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .frame(height: 30)
                        .background {
                            RoundedRectangle(cornerRadius: 100)
                                .fill(color.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100)
                                        .stroke(color, lineWidth: 1)
                                )
                        }

                        ScrollView {
                            VStack {
                                Text(exerciseReference.description)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                    .font(.body)
                                    .fontColor(.secondary)
                                    .padding(.bottom, 10)

                                DisclosureGroup {
                                    Text(exerciseReference.exerciseDescription)
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 16))
                                        .fontColor(.secondary)
                                        .padding(.vertical, 6)
                                } label: {
                                    HStack {
                                        Image(systemName: "info.circle")
                                        Text("How To Do")
                                    }
                                    .fontWeight(.bold)
                                    .font(.body)
                                    .fontColor(.primary)
                                }
                                .padding(10)
                                .enduraDefaultBox()
                            }
                            .lineSpacing(5)
                            .padding(.vertical, 10)
                        }
                    }

                    Spacer()

                    if exerciseReference.amountType != .time {
                        HStack {
                            Button("Next") {
                                withAnimation {
                                    if currentStep == totalSteps {
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
                                        if currentStep == totalSteps {
                                            finished = true
                                        } else {
                                            currentStep += 1
                                        }
                                    }
                                }
                                .buttonStyle(EnduraNewButtonStyle(backgroundColor: viewModel
                                        .currentTime >= Double(viewModel.exercise.amount) ? .accentColor : .gray))
                                .disabled(viewModel.currentTime < Double(viewModel.exercise.amount) * 2 / 3)
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
            .frame(maxHeight: .infinity, alignment: .top)
            .enduraPadding()
        }
    }
}

struct RoutineView: View {
    @StateObject private var viewModel = RoutineViewModel()
    @State private var currentPage = 0
    public var routine: RoutineData
    @Binding public var done: Bool

    public var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            var views: [AnyView] = routine.exercises.map { exercise in
                AnyView(RoutineExerciseView(
                    viewModel: RoutineExerciseViewModel(exercise: exercise),
                    currentStep: $currentPage,
                    totalSteps: routine.exercises.count
                ))
            }
            let _ = views.append(AnyView(Text("FINISHED")))

            MultiStepForm(views, viewModel: viewModel, currentPage: $currentPage)
        }
        .onChange(of: viewModel.done) { newValue in
            if newValue {
                done = true
            }
        }
    }
}
