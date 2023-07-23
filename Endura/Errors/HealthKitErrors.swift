//
// Created by Tobin Palmer on 7/22/23.
//

import Foundation

public enum HealthKitErrors: Error {
    case noWorkout
    case workoutFailedCast
    case authFailed
    case unknownError
}
