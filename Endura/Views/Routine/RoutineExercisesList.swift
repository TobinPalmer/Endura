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
                    HStack(alignment: .center) {
                        Circle()
                            .fill(ref.benefit.getColor())
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: ref.benefit.getIcon())
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }

                        Text("\(ref.name)")
                            .fontWeight(.bold)
                            .fontColor(.secondary)

                        Spacer()

                        HStack {
                            switch ref.amountType {
                            case .count:
                                Image(systemName: "repeat")
                                Text("x\(exercise.amount)")
                            case .time:
                                Image(systemName: "timer")
                                Text("\(exercise.amount)s")
                            case .distance:
                                Image(systemName: "ruler")
                                Text("\(exercise.amount)m")
                            }
                        }
                        .font(.body)
                        .fontWeight(.bold)
                        .fontColor(.secondary)
                    }
                    .alignFullWidth()
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
