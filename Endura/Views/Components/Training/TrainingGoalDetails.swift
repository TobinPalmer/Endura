import Foundation
import HealthKit
import SwiftUI
import WorkoutKit

private final class TrainingGoalDetailsModel: ObservableObject {
    @available(iOS 17.0, *)
    func generateRunningWorkout(_ goalData: RunningTrainingGoalData) async {
        if await WorkoutScheduler.shared.authorizationState != .authorized {
            if await WorkoutScheduler.shared.requestAuthorization() != .authorized {
                return
            }
        }

        let pacerWorkout = PacerWorkout(
            activity: .running,
            distance: Measurement(value: goalData.distance, unit: UnitLength.meters),
            time: Measurement(value: goalData.time, unit: UnitDuration.seconds)
        )

        let workoutPlan = WorkoutPlan(.pacer(pacerWorkout))

        await WorkoutScheduler.shared.schedule(workoutPlan, at: DateComponents())
    }
}

struct TrainingGoalDetails: View {
    @ObservedObject private var viewModel = TrainingGoalDetailsModel()
    private let goal: TrainingGoalData

    public init(_ goal: TrainingGoalData) {
        self.goal = goal
    }

    var body: some View {
        VStack {
            switch goal {
            case .routine:
                Text("Coming Soon")
            case let .run(data):
                Text("Distance: \(data.distance.removeTrailingZeros()) Miles")
                Text("Time: \(data.time.removeTrailingZeros()) Minutes")

                if data.progress.completed {
                    Text("Completed")
                } else {
                    Text("Not Completed")
                }

                if #available(iOS 17.0, *) {
                    Button("Add Workout to Watch") {
                        Task {
                            await viewModel.generateRunningWorkout(data)
                        }
                    }
                }
            }
        }
    }
}
