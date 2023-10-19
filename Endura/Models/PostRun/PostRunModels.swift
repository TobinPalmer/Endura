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
    public let type: RoutineType
    public let description: String
    public let exercises: [RoutineExercise]

    init(type: RoutineType, description: String, exercises: [RoutineExercise]) {
        self.type = type
        self.description = description
        self.exercises = exercises
    }
}
