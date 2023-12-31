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

    public func isCustomWorkout() -> Bool {
        switch self {
        case .custom:
            return true
        default:
            return false
        }
    }

    public func getWorkoutPlan() -> WorkoutPlan {
        switch self {
        case .open:
            return WorkoutPlan(.goal(SingleGoalWorkout(activity: .running, goal: .open)))
        case let .distance(distance):
            guard distance > 0 else {
                return WorkoutPlan(.goal(SingleGoalWorkout(activity: .running, goal: .open)))
            }
            return WorkoutPlan(.goal(SingleGoalWorkout(activity: .running, goal: .distance(distance, .miles))))
        case let .time(time):
            return WorkoutPlan(.goal(SingleGoalWorkout(activity: .running, goal: .time(time, .seconds))))
        case let .pacer(distance, time):
            guard distance > 0 && time > 0 else {
                return WorkoutPlan(.goal(SingleGoalWorkout(activity: .running, goal: .open)))
            }
            return WorkoutPlan(.pacer(PacerWorkout(
                activity: .running,
                distance: Measurement(value: distance, unit: UnitLength.miles),
                time: Measurement(value: time, unit: UnitDuration.seconds)
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
            return "circle"
        case .distance:
            return "figure.run"
        case .time:
            return "clock"
        case .pacer:
            return "timer"
        case .custom:
            return "gearshape"
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

    public func getTime() -> Double {
        blocks.reduce(0) { total, block in
            total + block.steps.reduce(0) { total, step in
                if case let .time(time) = step.goal {
                    return total + time
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
    public var steps: [CustomWorkoutStepData] = []
    public var iterations: Int = 1
}

public struct CustomWorkoutStepData: Codable, Hashable {
    public var type: CustomWorkoutStepType = .work
    public var goal: CustomWorkoutStepGoal = .open
}

public enum CustomWorkoutStepGoal: Codable, Hashable {
    case open
    case distance(
        distance: Double
    )
    case time(
        time: Double
    )

    public static let allCases: [CustomWorkoutStepGoal] = [
        .open,
        .distance(distance: 0),
        .time(time: 0),
    ]

    public func getStepGoal() -> WorkoutGoal {
        switch self {
        case .open:
            return .open
        case let .distance(distance):
            return .distance(distance, .miles)
        case let .time(time):
            return .time(time, .seconds)
        }
    }
}

public enum CustomWorkoutStepType: String, Codable, Hashable {
    case work = "Run"
    case recovery = "Recover"

    public func getStepPurpose() -> IntervalStep.Purpose {
        switch self {
        case .work:
            return .work
        case .recovery:
            return .recovery
        }
    }
}
