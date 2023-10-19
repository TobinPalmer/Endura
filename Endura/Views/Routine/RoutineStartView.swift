import Foundation
import SwiftUI

struct RoutineStartView: View {
    private let routineData: TrainingRoutineGoalData

    public init(_ routineData: TrainingRoutineGoalData) {
        self.routineData = routineData
    }

    public var body: some View {
        VStack {
            Text("Post Run Starting view")
        }
    }
}
