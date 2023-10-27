import Foundation
import SwiftUI

struct GenerateRoutineView: View {
    @Binding public var routineData: RoutineData
    @State private var routine: RoutineData

    public init(_ routineData: Binding<RoutineData>) {
        _routineData = routineData
        _routine = State(initialValue: routineData.wrappedValue)
    }

    var body: some View {
        VStack {
            Text("Generate")

//                    Task {
//                        let postRunRoutine = await TrainingGenerationUtils.generatePostRunRoutine(
//                            activeUser: activeUser
//                        )
//                        if let postRunRoutine = postRunRoutine {
//                            DispatchQueue.main.async {
//                                self.routine = postRunRoutine
//                            }
//                        }
//                    }
        }
    }
}
