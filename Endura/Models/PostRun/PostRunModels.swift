import Foundation
import SwiftUI

public struct RoutineExerciseInfo {
    public let easy: RoutineExerciseParameter
    public let medium: RoutineExerciseParameter
    public let hard: RoutineExerciseParameter

    public let name: String
    public let benefit: RoutineExerciseBenefit
    public let description: String
    public let exerciseDescription: String
    public let icon: Image? = nil
    public let reference: String?
}

public struct RoutineData {
    var exercises = [RoutineExercise]()

    init(_ routineData: [RoutineExercise]) {
        exercises = routineData
    }
}
