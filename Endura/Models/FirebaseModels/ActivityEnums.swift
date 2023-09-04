import Foundation

public enum GraphType: String, Codable {
    case cadence
    case elevation
    case groundContactTime
    case heartRate
    case pace
    case power
    case strideLength
    case verticalOscillation
}

public enum RunningScheduleType: String, Codable {
    case FREE = "free"
    case BUSY = "busy"
    case MAYBE = "maybe"
    case PROBABLY = "probably"
    case PROBABLY_NOT = "probably_not"
}

public enum ActivityType: String, Codable {
    case long = "Long Run"
    case hard = "Hard Run"
    case normal = "Normal Run"
    case none
}
