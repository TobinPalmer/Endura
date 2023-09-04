import Foundation

public struct WeeklyGraphData: Hashable, Codable {
    public var day: Days
    public var distance: Double
}

public struct WeeklySummaryData: Codable {
    public var id: String
    public var days: [DailySummaryData]
}

public struct DailySummaryData: Codable {
    public var id: String
    public var date: Date
    public var day: Days
    public var distance: Double
    public var duration: Double
    public var averageHeartRate: Double
    public var elevation: Double
}
