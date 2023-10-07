import Foundation
import HealthKit
import SwiftUI
import WorkoutKit

private final class TrainingGoalDetailsModel: ObservableObject {
    func generateRunningWorkout(_: RunningTrainingGoalData) async {
        await WorkoutScheduler.shared.requestAuthorization()
        print("Supported: \(WorkoutScheduler.isSupported)")
        print("Authorized: \(await WorkoutScheduler.shared.authorizationState)")
        if await WorkoutScheduler.shared.authorizationState != .authorized {
            if await WorkoutScheduler.shared.requestAuthorization() != .authorized {
                return
            }
        }

//        let pacerWorkout = PacerWorkout(
//            activity: .running,
//            distance: Measurement(value: goalData.distance, unit: UnitLength.miles),
//            time: Measurement(value: goalData.time, unit: UnitDuration.minutes)
//        )

        let step1 = IntervalStep(.work, goal: .distance(0.1, .miles))

        let block1 = IntervalBlock(steps: [step1], iterations: 2)

        let customWorkout = CustomWorkout(
            activity: .running,
            displayName: "Clean Workout",
            blocks: [block1]
        )

        let workoutPlan = WorkoutPlan(.custom(customWorkout))

        var daysAheadComponents = DateComponents()
        daysAheadComponents.day = 0
        daysAheadComponents.hour = 1

        guard let nextDate = Calendar.autoupdatingCurrent.date(byAdding: daysAheadComponents, to: .now) else {
            return
        }

        let nextDateComponents = Calendar.autoupdatingCurrent.dateComponents(in: .autoupdatingCurrent, from: nextDate)

        await WorkoutScheduler.shared.schedule(workoutPlan, at: nextDateComponents)
    }
}

struct TrainingGoalDetails: View {
    @ObservedObject private var viewModel = TrainingGoalDetailsModel()
    private let goal: TrainingGoalData

    public init(_ goal: TrainingGoalData) {
        self.goal = goal
    }

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack {
                switch goal {
                case .routine:
                    Text("Coming Soon")
                case let .run(data):
//                Text("Distance: \(data.distance.removeTrailingZeros()) Miles")
//                Text("Time: \(data.time.removeTrailingZeros()) Minutes")

                    if data.progress.completed {
                        Text("Completed")
                    } else {
                        Text("Not Completed")
                    }

                    if #available(iOS 17.0, *) {
                        Button("Authorize Workouts") {
                            Task {
                                await WorkoutScheduler.shared.requestAuthorization()
                            }
                        }

                        Button("Add Workout to Watch") {
                            Task {
                                await viewModel.generateRunningWorkout(data)
                            }
                        }
                    }
                }
            }
            .navigationBarItems(trailing: EditTrainingGoalLink(goal: goal) {
                Text("Edit")
            })
        }
    }
}
