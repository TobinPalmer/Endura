import Foundation

public enum PostRunExerciseBenifit: String {
    case legs = "Legs"
    case arms = "Arms"
    case core = "Core"
    case cardio = "Cardio"
    case none
}

public enum PostRunExerciseParameter: Hashable {
    case time(TimeInterval)
    case count(Int)
}

public enum PostRunExerciseType: Hashable {
    case plank
    case pushup
    case squat
    case lunge
}

public struct PostRunExercise: Hashable {
    var type: PostRunExerciseType
    var parameter: PostRunExerciseParameter?
}
