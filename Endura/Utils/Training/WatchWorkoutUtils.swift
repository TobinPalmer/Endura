import Foundation
import SwiftUICalendar
import WorkoutKit

public enum WatchWorkoutUtils {
    private static func requestAuthorization() async -> Bool {
        if await WorkoutScheduler.shared.authorizationState == .notDetermined {
            await WorkoutScheduler.shared.requestAuthorization()
        }
        return await WorkoutScheduler.shared.authorizationState == .authorized
    }

    public static func updateWorkouts(_ workoutGoals: [YearMonthDay: WorkoutGoalData]) {
        Task {
            if await requestAuthorization() {
                await WorkoutScheduler.shared.removeAllWorkouts()

                for workoutGoal in workoutGoals {
                    let workoutPlan = workoutGoal.value.getWorkoutPlan()

                    var dayComponents = DateComponents()
                    dayComponents.day = 0
                    dayComponents.hour = 1

                    guard let nextDate = Calendar.autoupdatingCurrent.date(
                        byAdding: dayComponents,
                        to: workoutGoal.key.getDate()
                    ) else {
                        return
                    }

                    let nextDateComponents = Calendar.autoupdatingCurrent.dateComponents(
                        in: .autoupdatingCurrent,
                        from: nextDate
                    )

                    await WorkoutScheduler.shared.schedule(workoutPlan, at: nextDateComponents)
                }
            }
        }
    }
}
