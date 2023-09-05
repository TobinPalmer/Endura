import Foundation
import SwiftUI

public struct PostRunExerciseInfo {
    public var easy: PostRunExerciseParameter
    public var medium: PostRunExerciseParameter
    public var hard: PostRunExerciseParameter

    public var name: String
    public var benefit: PostRunExerciseBenifit
    public var description: String
    public var exerciseDescription: String
    public var icon: Image
    public var reference: String?
}

public struct PostRun {
    var exercises = [PostRunExercise]()

    init(_ postRunData: [PostRunExercise]) {
        exercises = postRunData
    }
}
