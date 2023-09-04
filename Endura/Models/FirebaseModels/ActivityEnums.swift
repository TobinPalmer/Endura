import Foundation

public enum ActivityVisibility: String, Codable {
    case everyone
    case friends
    case none
}

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
