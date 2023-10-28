import Foundation
import SwiftUI

struct RoutineStartView: View {
    @EnvironmentObject private var activeUser: ActiveUserModel
    private let routineData: TrainingRoutineGoalData

    @State private var routine: RoutineData

    public init(_ data: TrainingRoutineGoalData) {
        routineData = data
        if routineData.type == .postRun {
            routine = defaultUserPostRuns[routineData.difficulty]!
        } else {
            routine = defaultUserWarmups[routineData.difficulty]!
        }
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

            NavigationLink(destination: GenerateRoutineView($routine)) {
                Text("Generate New Routine")
            }
            .buttonStyle(EnduraNewButtonStyle(
                backgroundColor: Color("TextMuted").opacity(0.3),
                color: Color("Text").opacity(0.6)
            ))
            .padding(.top, 6)

            Spacer()

            NavigationLink(destination: RoutineView(routine: routine)) {
                Text("Start")
            }
            .buttonStyle(EnduraNewButtonStyle())
        }
        .enduraPadding()
    }
}
