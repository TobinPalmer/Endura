import Foundation
import WorkoutKit

public enum WorkoutGoalData: Codable, Hashable {
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

    public func getWorkoutPlan() -> WorkoutPlan {
        switch self {
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
}

public struct CustomWorkoutData: Codable, Hashable {
    public var name: String
    public var blocks: [CustomWorkoutBlockData]

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
