import Foundation

public struct ActivityCommentData: Codable, Hashable {
    let message: String
    let time: Date
    let uid: String
}

public struct RouteData: Codable {
    public let altitude: Double
    public let distance: Double
    public let heartRate: Double
    public let location: LocationData
    public let pace: Double
    public let timestamp: Date
}

/// The same as RouteData, but with a fraction of the values to be more optimised for graphing and quick preview
public struct GraphData: Codable {
    public let altitude: Double
    public let cadence: Double
    public let distance: Double
    public let heartRate: Double
    public let groundContactTime: Double
    public let pace: Double
    public let power: Double
    public let strideLength: Double
    public let timestamp: Date
    public let verticalOscillation: Double
}

public struct ExtractedGraphData {
    public let pace: IndexedLineGraphData
    public let cadence: IndexedLineGraphData
    public let elevation: IndexedLineGraphData
    public let heartRate: IndexedLineGraphData
    public let power: IndexedLineGraphData
    public let strideLength: IndexedLineGraphData
    public let verticalOscillation: IndexedLineGraphData
}

public struct ActivityRouteData: Codable {
    public let graphData: [GraphData]
    public let graphInterval: Int
    public let routeData: [RouteData]
}

public struct ActivityGridStatsData: Codable {
    public var averagePower: Double?
    public let calories: Double
    public let distance: Double
    public let duration: TimeInterval
    var pace: Double {
        distance / duration
    }

    public let time: Date
    public let totalDuration: TimeInterval
    public let uid: String
}

public struct ActivityHeaderData: Codable {
    public let startTime: Date
    public var startLocation: LocationData?
    public var startCountry: String?
    public var startCity: String?
    public let uid: String
}

public struct ActivitySplitsData: Codable {
    public let distance: Double
    public let time: TimeInterval
    public let pace: TimeInterval
}

public struct LocationData: Codable {
    public let latitude: Double
    public let longitude: Double
}

public struct HeartRateData: Codable, TimestampPoint {
    public let timestamp: Date
    public let heartRate: Double
}

public struct CadenceData: Codable, TimestampPoint {
    public let timestamp: Date
    public let cadence: Double
}

public struct PowerData: Codable, TimestampPoint {
    public let timestamp: Date
    public let power: Double
}

public struct GroundContactTimeData: Codable, TimestampPoint {
    public let timestamp: Date
    public let groundContactTime: Double
}

public struct StrideLengthData: Codable, TimestampPoint {
    public let timestamp: Date
    public let strideLength: Double
}

public struct VerticalOscillationData: Codable, TimestampPoint {
    public let timestamp: Date
    public let verticalOscillation: Double
}

protocol TimestampPoint: Codable {
    var timestamp: Date { get }
}

public struct ActivityMetricsData {
    public let heartRate: Double
    public let cadence: Double
    public let power: Double?
    public let groundContactTime: Double?
    public let strideLength: Double?
    public let verticalOscillation: Double?
}
