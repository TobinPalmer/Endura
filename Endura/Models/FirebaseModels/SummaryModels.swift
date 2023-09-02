import Foundation

public enum Days: String, Codable, CaseIterable {
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    case sunday = "Sun"
}

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
