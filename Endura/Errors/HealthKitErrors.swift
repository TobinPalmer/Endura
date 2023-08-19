//
//  HealthKitErrors.swift created on 7/24/23.
//

import Foundation

public enum HealthKitErrors: Error {
    case noWorkout
    case workoutFailedCast
    case authFailed
    case unknownError
}
