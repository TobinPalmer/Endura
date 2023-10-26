import Foundation
import SwiftUI

struct RoutineStartView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    private let routineData: TrainingRoutineGoalData

    @State private var routine: RoutineData

    public init(_ data: TrainingRoutineGoalData) {
        routineData = data
        routine = defaultUserPostRuns[routineData.difficulty]!
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Today's \(routineData.type.rawValue)")
                    .font(.title)
                    .fontWeight(.bold)
                    .fontColor(.primary)

                ColoredBadge(routineData.difficulty)

                Text(routine.description)
                    .fontColor(.secondary)
                    .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity)

            ScrollView {
                RoutineExercisesList(routine.exercises)
            }

            Button {
                Task {
                    let postRunRoutine = await TrainingGenerationUtils.generatePostRunRoutine(
                        activeUser: activeUser
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

            Spacer()

            NavigationLink(destination: RoutineView(routine: routine)) {
                Button("Start") {}
                    .buttonStyle(EnduraNewButtonStyle())
            }
        }
        .enduraPadding()
    }
}
