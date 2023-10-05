import Foundation

public struct TrainingEndGoalData: Codable {
    public var date: Date
    public var startDate: Date
    public var distance: Double
    public var time: Double
    public var startTime: Double
    public var pace: Double {
        time / distance
    }

    public var completed: Bool
}
