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
            NavigationView {
                VStack {
                    switch goal {
                    case let .routine(data):
                        EditRoutineTrainingGoalView(goal: data)
                    case let .run(data):
                        EditRunningTrainingGoalView(goal: data)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            showEditGoal = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

struct EditTrainingDayView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    var selectedDate: YearMonthDay

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack {
                Text("Edit Training Plan for \(FormattingUtils.dateToFormattedDay(selectedDate))")
                    .font(.title)
                    .padding()
                Text("Current Plan")
                    .font(.title2)
                let trainingDay = activeUser.training.getTrainingDay(selectedDate)
                Text("Day: \(trainingDay.type.rawValue)").foregroundColor(trainingDay.type.getColor())

                Picker("Type", selection: Binding(
                    get: { trainingDay.type },
                    set: { newValue in
                        activeUser.training.updateTrainingDayType(selectedDate, newValue)
                    }
                )) {
                    ForEach(TrainingDayType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }

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
}
