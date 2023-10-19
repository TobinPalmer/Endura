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

public struct RoutineExercise: Hashable, Codable {
    public var type: RoutineExerciseType
    public var parameter: RoutineExerciseParameter

    public init(_ type: RoutineExerciseType, _ parameter: RoutineExerciseParameter) {
        self.type = type
        self.parameter = parameter
    }
}

public struct RoutineData: Codable {
    public var type: RoutineType
    public var description: String
    public var exercises: [RoutineExercise]

    init(type: RoutineType, description: String, exercises: [RoutineExercise]) {
        self.type = type
        self.description = description
        self.exercises = exercises
    }
}
