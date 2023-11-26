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
                VStack(alignment: .leading) {
                    HStack {
                        Text("Time: ")

                        Spacer()

                        TimeInput(time: Binding(
                            get: { time },
                            set: { newValue in
                                goal = .pacer(distance: distance, time: newValue)
                            }
                        ))
                    }
                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)

                    HStack {
                        Text("Distance: ")

                        Spacer()

                        DistanceInput(distance: Binding(
                            get: { distance },
                            set: { newValue in
                                goal = .pacer(distance: newValue, time: time)
                            }
                        ))
                    }
                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)

                    Spacer()
                        .frame(height: 20)

                    Spacer()
                        .frame(height: 20)

                    HStack {
                        Text("Pace: ")

                        Spacer()

                        let pace = distance / time
                        Text("\(ConversionUtils.convertMpsToMpm(pace * 1609.344)) / mi")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 20)
                .border(.red)

            case let .custom(data):
                Text("Custom Workout")
                EditCustomWorkout(data: Binding(
                    get: {
                        data
                    },
                    set: { newValue in
                        goal = .custom(data: newValue)
                    }
                ))
            }
        }
        .frame(width: UIScreen.main.bounds.width - 20)
    }
}
