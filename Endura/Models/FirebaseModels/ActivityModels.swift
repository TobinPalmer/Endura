import FirebaseFirestore
import Foundation
import MapKit

public struct RunningSchedule: Codable {
    public var day: Int
    public var type: RunningScheduleType
}

protocol ActivityDataProtocol {
    var averagePower: Double? { get }
    var calories: Double { get }
    var distance: Double { get }
    var duration: TimeInterval { get }
    var time: Date { get }
    var totalDuration: TimeInterval { get }
    var uid: String { get }
    var startCountry: String { get }
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
            startCountry: startCountry,
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

public struct ActivityDocument: Codable {
    var averagePower: Double?
    var calories: Double
    var comments: [ActivityCommentData]
    var distance: Double
    var description: String
    var duration: TimeInterval
    var likes: [String]
    var type: ActivityType
    var startCountry: String
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
            startCountry: activity.startCountry,
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

protocol TimestampPoint: Codable {
    var timestamp: Date { get }
}

extension CadenceData: TimestampPoint {}

extension HeartRateData: TimestampPoint {}

extension PowerData: TimestampPoint {}

extension StrideLengthData: TimestampPoint {}

extension GroundContactTimeData: TimestampPoint {}

extension VerticalOscillationData: TimestampPoint {}
