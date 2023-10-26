import Foundation
import SwiftUI

struct RoutineExercisesList: View {
    private let exercises: [RoutineExercise]

    public init(_ exercises: [RoutineExercise]) {
        self.exercises = exercises
    }

    var body: some View {
        VStack {
            ForEach(exercises, id: \.self) { exercise in
                if let ref: RoutineExerciseInfo = routineExerciseReference[exercise.type] {
                    HStack {
                        Text("\(ref.name)")

                        HStack {
                            switch ref.amountType {
                            case .count:
                                Image(systemName: "multiply")
                                Text("\(exercise.amount)")
                            case .time:
                                Image(systemName: "timer")
                                Text("\(exercise.amount)")
                            case .distance:
                                Image(systemName: "ruler")
                                Text("\(exercise.amount)")
                            }
                        }
                    }
                }
            }
        }
    }
}
