import Foundation
import SwiftUI
import SwiftUICalendar

struct EditTrainingGoalLink<Label: View>: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State private var showEditGoal = false
    @State var goal: TrainingRunGoalData
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
                EditTrainingRunGoalView(goal)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Done") {
                                showEditGoal = false
                            }
                        }
                    }
            }
            .presentationDetents(goal.workout.isCustomWorkout() ? [.large] : [.medium])
        }
    }
}

struct EditTrainingRunGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @Environment(\.dismiss) var dismiss
    @State var goal: TrainingRunGoalData

    public init(_ goal: TrainingRunGoalData, workoutGoal: WorkoutGoalData? = nil) {
        var goal = goal
        goal.workout = workoutGoal ?? goal.workout
        print("Goal: \(goal) - \(goal.workout)")
        _goal = State(initialValue: goal)
    }

    var body: some View {
        VStack {
            Picker("Type", selection: $goal.type) {
                ForEach(TrainingRunType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            TextField("Description", text: $goal.description)
            Toggle("Warmup", isOn: Binding(
                get: { goal.preRoutine != nil },
                set: { newValue in
                    if newValue {
                        goal.preRoutine = goal.getRoutine(routineType: .warmup)
                    } else {
                        goal.preRoutine = nil
                    }
                }
            ))
            Toggle("Postrun", isOn: Binding(
                get: { goal.postRoutine != nil },
                set: { newValue in
                    if newValue {
                        goal.postRoutine = goal.getRoutine(routineType: .postRun)
                    } else {
                        goal.postRoutine = nil
                    }
                }
            ))
            EditTrainingRunWorkout(goal: Binding(
                get: { goal.workout },
                set: { newValue in
                    goal.workout = newValue
                }
            ))
            Spacer()
            Button {
                activeUser.training.updateTrainingGoal(
                    goal.date,
                    goal
                )
                var trainingDay = activeUser.training.getTrainingDay(goal.date)
                trainingDay.type = goal.type.toTrainingDayType()
                activeUser.training.updateTrainingDay(goal.date, trainingDay)
                dismiss()
            } label: {
                Text("Save")
            }
            .buttonStyle(EnduraNewButtonStyle())
        }
        .enduraPadding()
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
