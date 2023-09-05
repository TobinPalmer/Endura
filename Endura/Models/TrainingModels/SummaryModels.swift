import Foundation

public struct WeeklyGraphData: Hashable, Codable {
    public let day: Days
    public var distance: Double
}

public struct WeeklySummaryData: Codable {
    public let id: String
    public let days: [DailySummaryData]
}

public struct DailySummaryData: Codable {
    public let id: String
    public let date: Date
    public let day: Days
    public let distance: Double
    public let duration: Double
    public let averageHeartRate: Double
    public let elevation: Double
}
