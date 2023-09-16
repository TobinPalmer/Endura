import Foundation
import SwiftUI

public struct PostRunExerciseInfo {
    public let easy: PostRunExerciseParameter
    public let medium: PostRunExerciseParameter
    public let hard: PostRunExerciseParameter

    public let name: String
    public let benefit: PostRunExerciseBenifit
    public let description: String
    public let exerciseDescription: String
    public let icon: Image
    public let reference: String?
}

public struct PostRun {
    var exercises = [PostRunExercise]()

    init(_ postRunData: [PostRunExercise]) {
        exercises = postRunData
    }
}
