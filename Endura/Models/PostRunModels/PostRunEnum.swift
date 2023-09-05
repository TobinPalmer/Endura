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

public enum PostRunExercise: Hashable {
    case plank(PostRunExerciseParameter = .time(10))
    case pushup(PostRunExerciseParameter = .count(10))
    case squat(PostRunExerciseParameter = .count(10))
    case lunge(PostRunExerciseParameter = .count(10))
}
