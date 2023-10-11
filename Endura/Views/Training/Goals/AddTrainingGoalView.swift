import Foundation
import SwiftUI
import SwiftUICalendar

struct AddTrainingGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    public var selectedDate: YearMonthDay

    init(_ selectedDate: YearMonthDay) {
        self.selectedDate = selectedDate
    }

    var body: some View {
        VStack {
            Text("Add Training Goal")
                .font(.title)
                .padding()
            NavigationLink(destination: Text("Coming Soon")) {
                Text("Add Routine Goal")
            }
            NavigationLink(destination: VStack {
                NavigationLink(destination: EditRunningTrainingGoalView(goal: TrainingRunGoalData(
                    date: selectedDate,
                    workout: .open
                ))) {
                    Text("Open Workout")
                }
                NavigationLink(destination: EditRunningTrainingGoalView(goal: TrainingRunGoalData(
                    date: selectedDate,
                    workout: .distance(distance: 0)
                ))) {
                    Text("Distance Workout")
                }
                NavigationLink(destination: EditRunningTrainingGoalView(goal: TrainingRunGoalData(
                    date: selectedDate,
                    workout: .time(time: 0)
                ))) {
                    Text("Time Workout")
                }
                NavigationLink(destination: EditRunningTrainingGoalView(goal: TrainingRunGoalData(
                    date: selectedDate,
                    workout: .pacer(distance: 0, time: 0)
                ))) {
                    Text("Pacer Workout")
                }
                NavigationLink(destination: EditRunningTrainingGoalView(goal: TrainingRunGoalData(
                    date: selectedDate,
                    workout: .custom(data: CustomWorkoutData())
                ))) {
                    Text("Custom Workout")
                }
            }) {
                Text("Add Running Goal")
            }
            Spacer()
        }
    }
}

struct AddOpenRunGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State var goal: TrainingRunGoalData

    var body: some View {
        VStack {
            Text("Open Workout")
            Spacer()
        }
    }
}

struct AddDistanceRunGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State var goal: TrainingRunGoalData

    var body: some View {
        VStack {
            Text("Distance Workout")
            Spacer()
        }
    }
}
