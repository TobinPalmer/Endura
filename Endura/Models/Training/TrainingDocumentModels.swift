import Foundation
import SwiftUICalendar

public struct DailyTrainingDataDocument: Codable {
    public var date: String
    public var type: TrainingDayType
    public var goals: [TrainingRunGoalDataDocument]
    public var summary: DailySummaryData?

    public func toJSON() -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("Error encoding JSON: \(error)")
            return ""
        }
    }

    public static func fromJSON(_ json: String) -> DailyTrainingDataDocument? {
        if json == "{}" || json == "" {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let data = json.data(using: .utf8)!
            return try decoder.decode(DailyTrainingDataDocument.self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}

public struct TrainingRunGoalDataDocument: Codable, Hashable {
    public var date: String
    public var type: TrainingRunType
    public var description: String
    public var preRoutine: TrainingRoutineGoalData?
    public var workout: WorkoutGoalData
    public var postRoutine: TrainingRoutineGoalData?
    public var progress: TrainingGoalProgressData?

    init(_ data: TrainingRunGoalData) {
        date = data.date.toCache()
        type = data.type
        description = data.description
        preRoutine = data.preRoutine
        workout = data.workout
        postRoutine = data.postRoutine
        progress = data.progress
    }

    public func toTrainingRunGoalData() -> TrainingRunGoalData {
        TrainingRunGoalData(
            date: YearMonthDay.fromCache(date),
            type: type,
            description: description,
            preRoutine: preRoutine,
            workout: workout,
            postRoutine: postRoutine,
            progress: progress ?? .init(workoutCompleted: false, activity: nil)
        )
    }

    public func getTitle() -> String {
        switch workout {
        case .open:
            return "Open Run"
        case let .distance(distance):
            return "\(FormattingUtils.formatMiles(distance)) Mile Run"
        case let .time(time):
            return "\(FormattingUtils.secondsToFormattedTime(time)) Run"
        case let .pacer(distance, time):
            return "\(FormattingUtils.formatMiles(distance)) Mile Run in \(FormattingUtils.secondsToFormattedTime(time))"
        case let .custom(data):
            return "Custom Workout"
        }
    }

    public func getDistance() -> Double {
        switch workout {
        case .open:
            return 0
        case let .distance(distance):
            return distance
        case .time:
            return 0
        case let .pacer(distance, _):
            return distance
        case let .custom(data):
            return data.getDistance()
        }
    }

    public func getTime() -> Double {
        switch workout {
        case .open:
            return 0
        case .distance:
            return 0
        case let .time(time):
            return time
        case let .pacer(_, time):
            return time
        case let .custom(data):
            return data.getTime()
        }
    }
}
