import Foundation

public enum HealthKitErrors: Error {
    case noWorkout
    case workoutFailedCast
    case authFailed
    case unknownError
}
