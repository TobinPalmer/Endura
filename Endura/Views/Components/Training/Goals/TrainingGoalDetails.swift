import Foundation
import HealthKit
import SwiftUI
import WorkoutKit

private final class TrainingGoalDetailsModel: ObservableObject {
    func generateRunningWorkout(_: TrainingRunGoalData) async {
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
    private let goal: TrainingRunGoalData

    public init(_ goal: TrainingRunGoalData) {
        self.goal = goal
    }

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text(goal.getTitle())
                        .font(.title)
                        .fontWeight(.bold)
                        .fontColor(.primary)
                        .alignFullWidth()

                    Spacer()

                    if goal.progress.workoutCompleted {
                        Image(systemName: "checkmark")
                            .font(.title)
                            .foregroundColor(Color("EnduraBlue"))
                    }
                }

                ColoredBadge(
                    text: goal.type.rawValue,
                    color: goal.type.getColor()
                )
                .alignFullWidth()

                Text(goal.description)
                    .font(.body)
                    .fontColor(.secondary)
                    .padding(.top, 5)
                    .alignFullWidth()

                HStack {
                    VStack {
                        Text("Distance")
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                            .alignFullWidth()
                        Text("\(FormattingUtils.formatMiles(goal.getDistance())) mi")
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                            .alignFullWidth()
                    }
                    VStack {
                        Text("Time")
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                            .alignFullWidth()
                        Text(FormattingUtils.secondsToFormattedTime(goal.getTime()))
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontColor(.primary)
                            .alignFullWidth()
                    }
                }
                .padding(.top, 8)
                .alignFullWidth(.center)

//                Text("Distance: \(data.distance.removeTrailingZeros()) Miles")
//                Text("Time: \(data.time.removeTrailingZeros()) Minutes")

//                if goal.progress.completed {
//                    Text("Completed")
//                } else {
//                    Text("Not Completed")
//                }
//
//                if #available(iOS 17.0, *) {
//                    Button("Authorize Workouts") {
//                        Task {
//                            await WorkoutScheduler.shared.requestAuthorization()
//                        }
//                    }
//
//                    Button("Add Workout to Watch") {
//                        Task {
//                            await viewModel.generateRunningWorkout(goal)
//                        }
//                    }
//                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .enduraPadding()
            .navigationBarItems(trailing: EditTrainingGoalLink(goal: goal) {
                Text("Edit")
            })
        }
    }
}
