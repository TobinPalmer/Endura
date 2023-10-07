import Foundation

public struct ActivityPostData: Codable {
    public var title: String
    public var description: String
    public let startCity: String
    public let startCountry: String
    public var likes: [String]
    public var comments: [ActivityCommentData]
}

public struct ActivityStatsData: Codable {
    public let calories: Double
    public let averageHeartRate: Double?
    public let averagePower: Double?
    public let splits: [ActivitySplitsData]
}

public struct ActivityData: Codable {
    public let uid: String
    public let time: Date
    public let visibility: ActivityVisibility

    public let type: TrainingRunType
    public let distance: Double
    public let duration: TimeInterval
    public let totalDuration: TimeInterval
    public var pace: Double {
        distance / duration
    }

    public let stats: ActivityStatsData

    public var social: ActivityPostData

    public func withRouteData(id: String) async -> ActivityDataWithRoute {
        let routeData = await ActivityUtils.getActivityRouteData(id: id)
        return ActivityDataWithRoute(
            uid: uid,
            time: time,
            visibility: visibility,
            type: type,
            distance: distance,
            duration: duration,
            totalDuration: totalDuration,
            stats: stats,
            social: social,
            data: routeData
        )
    }
}

public struct ActivityDataWithRoute: Codable {
    public let uid: String
    public let time: Date
    public var visibility: ActivityVisibility

    public let type: TrainingRunType
    public let distance: Double
    public let duration: TimeInterval
    public let totalDuration: TimeInterval
    public var pace: Double {
        distance / duration
    }

    public let stats: ActivityStatsData

    public var social: ActivityPostData

    public let data: ActivityRouteData

    public func getDataWithoutRoute() -> ActivityData {
        ActivityData(
            uid: uid,
            time: time,
            visibility: visibility,
            type: type,
            distance: distance,
            duration: duration,
            totalDuration: totalDuration,
            stats: stats,
            social: social
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
                paceGraph[val.timestamp.roundedToNearestSecond()] = val.pace
            }

            if val.cadence > 0 && !val.cadence.isNaN && !val.cadence.isInfinite {
                cadenceGraph[val.timestamp.roundedToNearestSecond()] = val.cadence
            }

            if val.altitude > 0 && !val.altitude.isNaN && !val.altitude.isInfinite {
                elevationGraph[val.timestamp.roundedToNearestSecond()] = val.altitude
            }

            if val.heartRate > 0 && !val.heartRate.isNaN && !val.heartRate.isInfinite {
                heartRateGraph[val.timestamp.roundedToNearestSecond()] = val.heartRate
            }

            if val.power > 0 && !val.power.isNaN && !val.power.isInfinite {
                powerGraph[val.timestamp.roundedToNearestSecond()] = val.power
            }

            if val.strideLength > 0 && !val.strideLength.isNaN && !val.strideLength.isInfinite {
                strideLengthGraph[val.timestamp.roundedToNearestSecond()] = val.strideLength
            }

            if val.verticalOscillation > 0 && !val.verticalOscillation.isNaN && !val.verticalOscillation.isInfinite {
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

public struct ActivityDocument: Codable {
    public let uid: String
    public let time: Date
    public let uploadTime: Date
    public let visibility: ActivityVisibility

    public let type: TrainingRunType
    public let distance: Double
    public let duration: TimeInterval
    public let totalDuration: TimeInterval
    public var pace: Double {
        distance / duration
    }

    public let stats: ActivityStatsData

    public let social: ActivityPostData

    public static func getDocument(for activity: ActivityDataWithRoute, uploadTime: Date) -> ActivityDocument {
        ActivityDocument(
            uid: activity.uid,
            time: activity.time,
            uploadTime: uploadTime,
            visibility: activity.visibility,
            type: activity.type,
            distance: activity.distance,
            duration: activity.duration,
            totalDuration: activity.totalDuration,
            stats: activity.stats,
            social: activity.social
        )
    }

    public func getActivityData() -> ActivityData {
        ActivityData(
            uid: uid,
            time: time,
            visibility: visibility,
            type: type,
            distance: distance,
            duration: duration,
            totalDuration: totalDuration,
            stats: stats,
            social: social
        )
    }
}
