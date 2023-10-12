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
    public var preRoutine: TrainingRoutineGoalData?
    public var workout: WorkoutGoalData
    public var postRoutine: TrainingRoutineGoalData?
    public var progress: TrainingGoalProgressData?

    init(_ data: TrainingRunGoalData) {
        date = data.date.toCache()
        preRoutine = data.preRoutine
        workout = data.workout
        postRoutine = data.postRoutine
        progress = data.progress
    }

    public func toTrainingRunGoalData() -> TrainingRunGoalData {
        TrainingRunGoalData(
            date: YearMonthDay.fromCache(date),
            preRoutine: preRoutine,
            workout: workout,
            postRoutine: postRoutine,
            progress: progress ?? .init(completed: false, activity: nil)
        )
    }
}
