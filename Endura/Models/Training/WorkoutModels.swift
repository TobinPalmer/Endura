import Foundation
import SwiftUI
import WorkoutKit

public enum WorkoutGoalData: Codable, Hashable {
    case open
    case distance(
        distance: Double
    )
    case time(
        time: Double
    )
    case pacer(
        distance: Double,
        time: Double
    )
    case custom(
        data: CustomWorkoutData
    )

    public static let allCases: [WorkoutGoalData] = [
        .open,
        .distance(distance: 0),
        .time(time: 0),
        .pacer(distance: 0, time: 0),
        .custom(data: CustomWorkoutData()),
    ]

    public func getWorkoutPlan() -> WorkoutPlan {
        switch self {
        case .open:
            return WorkoutPlan(.goal(SingleGoalWorkout(activity: .running, goal: .open)))
        case let .distance(distance):
            return WorkoutPlan(.goal(SingleGoalWorkout(activity: .running, goal: .distance(distance, .miles))))
        case let .time(time):
            return WorkoutPlan(.goal(SingleGoalWorkout(activity: .running, goal: .time(time, .minutes))))
        case let .pacer(distance, time):
            return WorkoutPlan(.pacer(PacerWorkout(
                activity: .running,
                distance: Measurement(value: distance, unit: UnitLength.miles),
                time: Measurement(value: time, unit: UnitDuration.minutes)
            )))
        case let .custom(data):
            return WorkoutPlan(.custom(CustomWorkout(
                activity: .running,
                displayName: data.name,
                blocks: data.getBlocks()
            )))
        }
    }

    public func getWorkoutIcon() -> String {
        switch self {
        case .open:
            return "questionmark.circle"
        case .distance:
            return "figure.walk"
        case .time:
            return "clock"
        case .pacer:
            return "figure.walk"
        case .custom:
            return "figure.walk"
        }
    }

    public func getWorkoutName() -> String {
        switch self {
        case .open:
            return "Open Run"
        case .distance:
            return "Distance Run"
        case .time:
            return "Timed Run"
        case .pacer:
            return "Pacer Run"
        case .custom:
            return "Custom Workout"
        }
    }

    public func getWorkoutDescription() -> String {
        switch self {
        case .open:
            return "An open workout, run whatever you want!"
        case .distance:
            return "A workout where you run a certain distance, regardless of time."
        case .time:
            return "A workout where you run for a certain amount of time, regardless of distance."
        case .pacer:
            return "A workout where you run a certain distance at a certain pace for a certain amount of time."
        case .custom:
            return "A workout where you run a custom workout, with custom intervals."
        }
    }
}

public struct CustomWorkoutData: Codable, Hashable {
    public var name: String = ""
    public var blocks: [CustomWorkoutBlockData] = []

    public func getDistance() -> Double {
        blocks.reduce(0) { total, block in
            total + block.steps.reduce(0) { total, step in
                if case let .distance(distance) = step.goal {
                    return total + distance
                }
                return total
            }
        }
    }

    public func getBlocks() -> [IntervalBlock] {
        blocks.map { block in
            IntervalBlock(steps: block.steps.map { step in
                IntervalStep(step.type.getStepPurpose(), goal: step.goal.getStepGoal())
            }, iterations: block.iterations)
        }
    }
}

public struct CustomWorkoutBlockData: Codable, Hashable {
    public var steps: [CustomWorkoutStepData]
    public var iterations: Int
}

public struct CustomWorkoutStepData: Codable, Hashable {
    public var type: CustomWorkoutStepType
    public var goal: CustomWorkoutStepGoal
}

public enum CustomWorkoutStepGoal: Codable, Hashable {
    case open
    case distance(
        distance: Double
    )
    case time(
        time: Double
    )

    public func getStepGoal() -> WorkoutGoal {
        switch self {
        case .open:
            return .open
        case let .distance(distance):
            return .distance(distance, .miles)
        case let .time(time):
            return .time(time, .minutes)
        }
    }
}

public enum CustomWorkoutStepType: String, Codable, Hashable {
    case work
    case recovery

    public func getStepPurpose() -> IntervalStep.Purpose {
        switch self {
        case .work:
            return .work
        case .recovery:
            return .recovery
        }
    }
}
