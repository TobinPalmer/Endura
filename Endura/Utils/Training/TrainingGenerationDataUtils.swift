import Foundation
import SwiftUICalendar

public enum TrainingGenerationDataUtils {
    public static func encodeEndTrainingGoal(_ endGoal: TrainingEndGoalData) -> String? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(TrainingEndGoalDocument(endGoal))
            return String(data: data, encoding: .utf8)
        } catch {
            Global.log.error("Error encoding end goal: \(error)")
        }
        return nil
    }

    // The output will be like:
    //   {
    //       "2021-08-01": {
    //           "workout": {
    //               "type": "time",
    //               "time": 3600
    //           }
    //       },
    //       "2021-08-02": {
    //           "workout": {
    //               "type": "distance",
    //                "distance": 10000
    //           }
    //       }
    //   }
    //

    public static func decodeOutputDailyGoals(_ data: Data) -> [YearMonthDay: DailyTrainingData] {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            print(data)
        } catch {
            Global.log.error("Error decoding output daily goals: \(error)")
        }
        return [:]
    }
}
