import Foundation
import SwiftUI

public struct RoutineExerciseInfo {
    public let easy: Int
    public let medium: Int
    public let hard: Int

    public let name: String
    public let benefit: RoutineExerciseBenefit
    public let description: String
    public let exerciseDescription: String
    public let amountType: RoutineExerciseAmountType
    public let icon: Image? = nil
    public let reference: String?
}

public struct RoutineExercise: Hashable, Codable {
    public var type: RoutineExerciseType
    public var amount: Int

    public init(_ type: RoutineExerciseType, _ amount: Int) {
        self.type = type
        self.amount = amount
    }
}

public struct RoutineData: Codable {
    public var type: RoutineType
    public var description: String
    public var exercises: [RoutineExercise]

    init(type: RoutineType, description: String = "", exercises: [RoutineExercise]) {
        self.type = type
        self.description = description
        self.exercises = exercises
    }
}
