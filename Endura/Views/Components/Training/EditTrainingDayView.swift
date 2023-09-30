import Foundation
import SwiftUI
import SwiftUICalendar

struct EditTrainingGoalLink: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State private var showEditGoal = false
    var goal: TrainingGoalData

    var body: some View {
        Button(action: {
            showEditGoal = true
        }) {
            Text("Edit")
        }
        .sheet(isPresented: $showEditGoal) {
            switch goal {
            case let .routine(data):
                EditRoutineTrainingGoalView(goal: data)
            case let .run(data):
                EditRunningTrainingGoalView(goal: data)
            }
        }
    }
}

private final class TrainingDayViewModel: ObservableObject {}

struct TrainingDayView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @StateObject private var viewModel = TrainingDayViewModel()
    var selectedDate: YearMonthDay

    var body: some View {
        VStack {
            Text("Edit Training Plan for \(FormattingUtils.dateToFormattedDay(selectedDate))")
                .font(.title)
                .padding()
            Text("Current Plan")
                .font(.title2)
            let trainingDay = activeUser.training.getTrainingDay(selectedDate)
            Text("Day: \(trainingDay.type.rawValue)").foregroundColor(trainingDay.type.getColor())
            if trainingDay.goals.isEmpty {
                Text("No goals for this day")
            } else {
                List {
                    ForEach(trainingDay.goals, id: \.self) { goal in
                        switch goal {
                        case let .routine(data):
                            NavigationLink(destination: EditRoutineTrainingGoalView(goal: data)) {
                                TrainingGoal(goal)
                            }
                        case let .run(data):
                            NavigationLink(destination: EditRunningTrainingGoalView(goal: data)) {
                                TrainingGoal(goal)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
    }
}
