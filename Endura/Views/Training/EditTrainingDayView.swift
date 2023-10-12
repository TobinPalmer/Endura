import Foundation
import SwiftUI
import SwiftUICalendar

struct EditTrainingGoalLink<Label: View>: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State private var showEditGoal = false
    var goal: TrainingRunGoalData
    private var content: () -> Label

    init(goal: TrainingRunGoalData, @ViewBuilder content: @escaping () -> Label) {
        self.goal = goal
        self.content = content
    }

    var body: some View {
        Button(action: {
            showEditGoal = true
        }) {
            content()
        }
        .sheet(isPresented: $showEditGoal) {
            NavigationView {
                VStack {
//                        EditTrainingRunWorkout(goal: goal)
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
                            EditTrainingGoalLink(goal: goal) {
                                TrainingGoal(goal)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                Spacer()
            }
        }
    }
}
