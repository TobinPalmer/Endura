import Foundation
import SwiftUI
import SwiftUICalendar

struct EditRunningTrainingGoalView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @State var goal: RunningTrainingGoalData

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack {
                switch goal.workout {
                case .open:
                    Text("Open Workout")
                case let .distance(distance):
                    Text("Distance: \(distance)")
                    DistanceInput(distance: Binding(
                        get: { distance },
                        set: { newValue in
                            goal.workout = .distance(distance: newValue)
                        }
                    ))
                case let .time(time):
                    Text("Time: \(time)")
                    TimeInput(time: Binding(
                        get: { time },
                        set: { newValue in
                            goal.workout = .time(time: newValue)
                        }
                    ))
                case let .pacer(distance, time):
                    Text("Distance: \(distance)")
                    Text("Time: \(time)")
                case let .custom(data):
                    Text("Custom Workout")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .enduraPadding()
            .onChange(of: goal) { _, newValue in
                activeUser.training.updateTrainingGoal(
                    goal.date.toYearMonthDay(),
                    TrainingGoalData.run(data: newValue)
                )
            }
        }
    }
}
