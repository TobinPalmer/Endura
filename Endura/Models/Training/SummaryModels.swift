import Foundation

public struct WeeklyGraphData: Hashable, Codable {
    public let day: Day
    public var distance: Double
}

public struct DailySummaryData: Codable {
    public var distance: Double
    public var duration: Double
    public var activities: Int

    public func getMiles() -> Double {
        distance * 0.000621371
    }
}
