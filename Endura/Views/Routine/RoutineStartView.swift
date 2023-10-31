import Foundation
import SwiftUI
import SwiftUICalendar

struct RoutineStartView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @Environment(\.dismiss) private var dismiss
    private let routineData: TrainingRoutineGoalData
    private let day: YearMonthDay

    @State private var routine: RoutineData
    @State private var done = false

    public init(_ data: TrainingRoutineGoalData, date: YearMonthDay) {
        day = date
        routineData = data
        _routine = State(initialValue: routineData
            .type == .postRun ? defaultUserPostRuns[routineData.difficulty]! :
            defaultUserWarmups[routineData.difficulty]!)
    }

    public var body: some View {
        VStack {
            Text("Today's \(routineData.type.rawValue)")
                .font(.title)
                .fontWeight(.bold)
                .fontColor(.primary)

            ColoredBadge(routineData.difficulty)

            Text(routine.description)
                .fontColor(.secondary)
                .padding(.vertical, 10)

            ScrollView {
                RoutineExercisesList(routine.exercises)
            }

            NavigationLink(destination: GenerateRoutineView($routine)) {
                Text("Generate New Routine")
            }
            .buttonStyle(EnduraNewButtonStyle(
                backgroundColor: Color("TextMuted").opacity(0.3),
                color: Color("Text").opacity(0.6)
            ))
            .padding(.top, 6)

            Spacer()

            NavigationLink(destination: RoutineView(routine: routine, done: $done)) {
                Text("Start")
            }
            .buttonStyle(EnduraNewButtonStyle())
        }
        .onChange(of: done) { newValue in
            if newValue {
                var trainingDay = activeUser.training.getTrainingDay(day)
                if routineData.type == .postRun {
                    trainingDay.goals[0].progress.postRoutineCompleted = true
                } else {
                    trainingDay.goals[0].progress.preRoutineCompleted = true
                }
                activeUser.training.updateTrainingDay(day, trainingDay)
                dismiss()
            }
        }
        .enduraPadding()
    }
}
