import Foundation

public struct WeeklyGraphData: Hashable, Codable {
    public let day: Day
    public var distance: Double
}

public struct DailySummaryData: Codable {
    public let distance: Double
    public let duration: Double
    public let activities: [String]
}
