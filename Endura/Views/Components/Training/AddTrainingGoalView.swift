import Foundation
import SwiftUI
import SwiftUICalendar

struct AddTrainingGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    public var selectedDate: YearMonthDay

    @Binding var rootIsActive: Bool

    init(_ selectedDate: YearMonthDay, rootIsActive: Binding<Bool>) {
        self.selectedDate = selectedDate
        _rootIsActive = rootIsActive
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
                let date = selectedDate.getDate()

                NavigationLink(destination: EditRunningTrainingGoalView(goal: RunningTrainingGoalData(
                    date: date,
                    workout: .open
                ))) {
                    Text("Open Workout")
                }
                NavigationLink(destination: EditRunningTrainingGoalView(goal: RunningTrainingGoalData(
                    date: date,
                    workout: .distance(distance: 0)
                ))) {
                    Text("Distance Workout")
                }
                NavigationLink(destination: EditRunningTrainingGoalView(goal: RunningTrainingGoalData(
                    date: date,
                    workout: .time(time: 0)
                ))) {
                    Text("Time Workout")
                }
                NavigationLink(destination: EditRunningTrainingGoalView(goal: RunningTrainingGoalData(
                    date: date,
                    workout: .pacer(distance: 0, time: 0)
                ))) {
                    Text("Pacer Workout")
                }
                NavigationLink(destination: EditRunningTrainingGoalView(goal: RunningTrainingGoalData(
                    date: date,
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
    @State var goal: RunningTrainingGoalData

    var body: some View {
        VStack {
            Text("Open Workout")
            Spacer()
        }
    }
}

struct AddDistanceRunGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State var goal: RunningTrainingGoalData

    var body: some View {
        VStack {
            Text("Distance Workout")
            Spacer()
        }
    }
}
