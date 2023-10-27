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
            Text("Today's \(routineData.type.rawValue)")
                .font(.title)
                .fontWeight(.bold)
                .fontColor(.primary)

            ColoredBadge(routineData.difficulty)

            Text(routine.description)
                .fontColor(.secondary)
                .padding(.vertical, 10)

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
                Text("Customize")
            }
            .buttonStyle(EnduraNewButtonStyle(
                backgroundColor: Color("TextMuted").opacity(0.5),
                color: Color("Text").opacity(0.8)
            ))
            .padding(.top, 6)

            Spacer()

            NavigationLink(destination: RoutineView(routine: routine)) {
                Button("Start") {}
                    .buttonStyle(EnduraNewButtonStyle())
            }
        }
        .enduraPadding()
    }
}
