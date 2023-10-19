import Foundation
import SwiftUI

struct RoutineStartView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    private let routineData: TrainingRoutineGoalData

    @State private var progress = 0

    @State private var routine: RoutineData?

    public init(_ routineData: TrainingRoutineGoalData) {
        self.routineData = routineData
    }

    public var body: some View {
        VStack {
            Text("Post Run Starting view")

            if let routine = routine {
                Text(routine.description)
                    .padding(.bottom, 10)
                ScrollView {
                    ForEach(routine.exercises, id: \.self) { exercise in
                        if let ref = routineExerciseReference[exercise.type] {
                            Text("\(ref.name) - \(String(describing: exercise.parameter))")
                        }
                    }
                }
            }

            ProgressView(value: Double(progress), total: 100)
                .padding(.vertical, 20)

            Button {
                Task {
                    let postRunRoutine = await TrainingGenerationUtils.generatePostRunRoutine(
                        activeUser: activeUser,
                        progress: { progress in
                            withAnimation {
                                self.progress = progress
                            }
                        }
                    )
                    if let postRunRoutine = postRunRoutine {
                        DispatchQueue.main.async {
                            self.routine = postRunRoutine
                        }
                    }
                }
            } label: {
                Text("Generate")
            }
        }
    }
}
