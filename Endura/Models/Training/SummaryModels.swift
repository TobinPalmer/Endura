import Foundation

public struct WeeklyGraphData: Hashable, Codable {
    public let day: Day
    public var distance: Double
}

public struct WeeklySummaryData: Codable {
    public let id: String
    public let days: [DailySummaryData]
}

public struct DailySummaryData: Codable {
    public let distance: Double
    public let duration: Double
    public let activities: [String]
}
