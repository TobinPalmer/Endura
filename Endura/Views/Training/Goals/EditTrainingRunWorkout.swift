import Foundation
import SwiftUI
import SwiftUICalendar

struct EditTrainingRunWorkout: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    @Binding var goal: WorkoutGoalData

    var body: some View {
        VStack {
            switch goal {
            case .open:
                Text("Open Workout")
            case let .distance(distance):
                Text("Distance: \(distance)")
                DistanceInput(distance: Binding(
                    get: { distance },
                    set: { newValue in
                        goal = .distance(distance: newValue)
                    }
                ))
            case let .time(time):
                Text("Time: \(time)")
                TimeInput(time: Binding(
                    get: { time },
                    set: { newValue in
                        goal = .time(time: newValue)
                    }
                ))
            case let .pacer(distance, time):
                Text("Distance: \(distance)")
                TimeInput(time: Binding(
                    get: { time },
                    set: { newValue in
                        goal = .pacer(distance: distance, time: newValue)
                    }
                ))
                Text("Time: \(time)")
                DistanceInput(distance: Binding(
                    get: { distance },
                    set: { newValue in
                        goal = .pacer(distance: newValue, time: time)
                    }
                ))
                Text("Pace: \(distance / time)")
            case let .custom(data):
                Text("Custom Workout")
            }
        }
        .enduraPadding()
    }
}
