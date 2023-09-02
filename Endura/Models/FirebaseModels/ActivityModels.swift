import FirebaseFirestore
import Foundation
import MapKit

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

public enum Days: String, Codable, CaseIterable {
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    case sunday = "Sun"
}

public typealias LineGraphData = [(Date, Double)]
public typealias IndexedLineGraphData = [Date: Double]

public typealias IndexedGraphData = [Date: GraphData]
public typealias IndexedRouteLocationData = [Date: LocationData]

public struct WeeklyGraphData: Hashable, Codable {
    public var day: Days
    public var distance: Double
}

public struct ActivityCommentData: Codable, Hashable {
    let message: String
    let time: Date
    let uid: String
}

public struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
}

public struct HeartRateData: Codable {
    var timestamp: Date
    var heartRate: Double
}

public struct CadenceData: Codable {
    var timestamp: Date
    var cadence: Double
}

public struct PowerData: Codable {
    var timestamp: Date
    var power: Double
}

public struct GroundContactTimeData: Codable {
    var timestamp: Date
    var groundContactTime: Double
}

public struct StrideLengthData: Codable {
    var timestamp: Date
    var strideLength: Double
}

public struct VerticalOscillationData: Codable {
    var timestamp: Date
    var verticalOscillation: Double
}

public struct RouteData: Codable {
    var altitude: Double
    var cadence: Double
    var heartRate: Double
    var groundContactTime: Double
    var location: LocationData
    var pace: Double
    var power: Double
    var strideLength: Double
    var timestamp: Date
    var verticalOscillation: Double
}

/// The same as RouteData, but with a fraction of the values to be more optimised for graphing and quick preview
public struct GraphData: Codable {
    var altitude: Double
    var cadence: Double
    var heartRate: Double
    var groundContactTime: Double
    var pace: Double
    var power: Double
    var strideLength: Double
    var timestamp: Date
    var verticalOscillation: Double
}

public struct ExtractedGraphData {
    var pace: IndexedLineGraphData
    var cadence: IndexedLineGraphData
    var elevation: IndexedLineGraphData
    var heartRate: IndexedLineGraphData
    var power: IndexedLineGraphData
    var strideLength: IndexedLineGraphData
    var verticalOscillation: IndexedLineGraphData
}

public struct ActivityRouteData: Codable {
    var graphData: [GraphData]
    var graphInterval: Int
    var routeData: [RouteData]
}

public struct ActivityGridStatsData: Codable {
    var averagePower: Double?
    var calories: Double
    var distance: Double
    var duration: TimeInterval
    var pace: Double {
        distance / duration
    }

    var time: Date
    var totalDuration: TimeInterval
    var uid: String
}

public struct ActivityHeaderData: Codable {
    var startTime: Date
    var startLocation: LocationData?
    var startCity: String?
    var uid: String
}

protocol ActivityDataProtocol {
    var averagePower: Double? { get }
    var calories: Double { get }
    var distance: Double { get }
    var duration: TimeInterval { get }
    var time: Date { get }
    var totalDuration: TimeInterval { get }
    var uid: String { get }
    var startCity: String { get }
    var startLocation: LocationData { get }
    var description: String { get }
    var title: String { get }

    func withHeaderStats() -> ActivityHeaderData
    func withGridStats() -> ActivityGridStatsData
}

extension ActivityDataProtocol {
    public func withHeaderStats() -> ActivityHeaderData {
        ActivityHeaderData(
            startTime: time,
            startLocation: startLocation,
            startCity: startCity,
            uid: uid
        )
    }

    public func withGridStats() -> ActivityGridStatsData {
        ActivityGridStatsData(
            averagePower: averagePower,
            calories: calories,
            distance: distance,
            duration: duration,
            time: time,
            totalDuration: totalDuration,
            uid: uid
        )
    }
}

public enum ActivityType: String, Codable {
    case long = "Long Run"
    case hard = "Hard Run"
    case normal = "Normal Run"
    case none
}

public struct ActivityDocument: Codable {
    var averagePower: Double?
    var calories: Double
    var comments: [ActivityCommentData]
    var distance: Double
    var description: String
    var duration: TimeInterval
    var likes: [String]
    var type: ActivityType
    var startCity: String
    var startLocation: LocationData
    var time: Date
    var title: String
    var totalDuration: TimeInterval
    var uid: String
    var uploadTime: Date

    static func getDocument(for activity: ActivityDataWithRoute, uploadTime: Date) -> ActivityDocument {
        ActivityDocument(
            averagePower: activity.averagePower,
            calories: activity.calories,
            comments: activity.comments,
            distance: activity.distance,
            description: activity.description,
            duration: activity.duration,
            likes: activity.likes,
            type: activity.type,
            startCity: activity.startCity,
            startLocation: activity.startLocation,
            time: activity.time,
            title: activity.title,
            totalDuration: activity.totalDuration,
            uid: activity.uid,
            uploadTime: uploadTime
        )
    }
}

public struct ActivityData: Codable, ActivityDataProtocol {
    var averagePower: Double?
    var calories: Double
    var comments: [ActivityCommentData]
    var distance: Double
    var description: String
    var duration: TimeInterval
    var likes: [String]
    var pace: Double {
        distance / duration
    }

    var type: ActivityType
    var startCity: String
    var startLocation: LocationData
    var time: Date
    var title: String
    var totalDuration: TimeInterval
    var uid: String

    public func withRouteData(id: String) async -> ActivityDataWithRoute {
        let routeData = await ActivityUtils.getActivityRouteData(id: id)
        return ActivityDataWithRoute(
            averagePower: averagePower,
            calories: calories,
            comments: comments,
            data: routeData,
            distance: distance,
            description: description,
            duration: duration,
            workoutStart: time,
            likes: likes,
            type: type,
            startCity: startCity,
            startLocation: startLocation,
            time: time,
            title: title,
            totalDuration: totalDuration,
            uid: uid
        )
    }
}

public struct ActivityDataWithRoute: Codable, ActivityDataProtocol {
    var averagePower: Double?
    var calories: Double
    var comments: [ActivityCommentData]
    var data: ActivityRouteData
    var distance: Double
    var description: String
    var duration: TimeInterval
    var workoutStart: Date
    var likes: [String]
    var pace: Double {
        distance / duration
    }

    var type: ActivityType
    var startCity: String
    var startLocation: LocationData
    var time: Date
    var title: String
    var totalDuration: TimeInterval
    var uid: String

    public func getDataWithoutRoute() -> ActivityData {
        ActivityData(
            averagePower: averagePower,
            calories: calories,
            comments: comments,
            distance: distance,
            description: description,
            duration: duration,
            likes: likes,
            type: type,
            startCity: startCity,
            startLocation: startLocation,
            time: time,
            title: title,
            totalDuration: totalDuration,
            uid: uid
        )
    }

    public func getIndexedGraphData() -> IndexedGraphData {
        var graphData = IndexedGraphData()

        data.graphData.forEach { val in
            graphData[val.timestamp.roundedToNearestSecond()] = val
        }

        return graphData
    }

    public func getIndexedRouteLocationData() -> IndexedRouteLocationData {
        var routeData = IndexedRouteLocationData()

        data.routeData.forEach { val in
            routeData[val.timestamp.roundedToNearestSecond()] = val.location
        }

        return routeData
    }

    public func getGraphData() -> ExtractedGraphData {
        var paceGraph = IndexedLineGraphData()
        var cadenceGraph = IndexedLineGraphData()
        var elevationGraph = IndexedLineGraphData()
        var heartRateGraph = IndexedLineGraphData()
        var powerGraph = IndexedLineGraphData()
        var strideLengthGraph = IndexedLineGraphData()
        var verticalOscillationGraph = IndexedLineGraphData()

        data.graphData.forEach { val in
            if val.pace > 0 && !val.pace.isNaN && !val.pace.isInfinite {
//                paceGraph.append((val.timestamp, val.pace))
                paceGraph[val.timestamp.roundedToNearestSecond()] = val.pace
            }

            if val.cadence > 0 && !val.cadence.isNaN && !val.cadence.isInfinite {
//                cadenceGraph.append((val.timestamp, val.cadence))
                cadenceGraph[val.timestamp.roundedToNearestSecond()] = val.cadence
            }

            if val.altitude > 0 && !val.altitude.isNaN && !val.altitude.isInfinite {
//                elevationGraph.append((val.timestamp, val.altitude))
                elevationGraph[val.timestamp.roundedToNearestSecond()] = val.altitude
            }

            if val.heartRate > 0 && !val.heartRate.isNaN && !val.heartRate.isInfinite {
//                heartRateGraph.append((val.timestamp, val.heartRate))
                heartRateGraph[val.timestamp.roundedToNearestSecond()] = val.heartRate
            }

            if val.power > 0 && !val.power.isNaN && !val.power.isInfinite {
//                powerGraph.append((val.timestamp, val.power))
                powerGraph[val.timestamp.roundedToNearestSecond()] = val.power
            }

            if val.strideLength > 0 && !val.strideLength.isNaN && !val.strideLength.isInfinite {
//                strideLengthGraph.append((val.timestamp, val.strideLength))
                strideLengthGraph[val.timestamp.roundedToNearestSecond()] = val.strideLength
            }

            if val.verticalOscillation > 0 && !val.verticalOscillation.isNaN && !val.verticalOscillation.isInfinite {
//                verticalOscillationGraph.append((val.timestamp, val.verticalOscillation))
                verticalOscillationGraph[val.timestamp.roundedToNearestSecond()] = val.verticalOscillation
            }
        }

        return ExtractedGraphData(
            pace: paceGraph,
            cadence: cadenceGraph,
            elevation: elevationGraph,
            heartRate: heartRateGraph,
            power: powerGraph,
            strideLength: strideLengthGraph,
            verticalOscillation: verticalOscillationGraph
        )
    }

    public func getGraph(for type: GraphType) -> LineGraphData {
        var graphData = LineGraphData()
        var selector: (GraphData) -> Double

        switch type {
        case .pace:
            selector = {
                $0.pace
            }
        case .heartRate:
            selector = {
                $0.heartRate
            }
        case .elevation:
            selector = {
                $0.altitude
            }
        case .cadence:
            selector = {
                $0.cadence
            }
        case .power:
            selector = {
                $0.power
            }
        case .groundContactTime:
            selector = {
                $0.groundContactTime
            }
        case .strideLength:
            selector = {
                $0.strideLength
            }
        case .verticalOscillation:
            selector = {
                $0.verticalOscillation
            }
        }

        data.graphData.forEach { val in
            if selector(val) > 0 && !selector(val).isNaN && !selector(val).isInfinite {
                graphData.append((val.timestamp, selector(val)))
            }
        }

        return graphData
    }
}

protocol TimestampPoint: Codable {
    var timestamp: Date { get }
}

extension CadenceData: TimestampPoint {}

extension HeartRateData: TimestampPoint {}

extension PowerData: TimestampPoint {}

extension StrideLengthData: TimestampPoint {}

extension GroundContactTimeData: TimestampPoint {}

extension VerticalOscillationData: TimestampPoint {}
