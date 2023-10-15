import Foundation
import SwiftUICalendar

public enum TrainingGenerationDataUtils {
    public static func encodeAthleteInfo(_ data: ActiveUserData) -> String {
        """
        {
            "age": \(data.getAge()),
            "gender": "\(data.gender.rawValue)",
            "weight": \(data.weight != nil ? "\(data.weight!)" : "n/a"),
        }
        """
    }

    public static func encodeEndTrainingGoal(_ endGoal: TrainingEndGoalData) -> String {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(TrainingEndGoalDocument(endGoal))
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            Global.log.error("Error encoding end goal: \(error)")
        }
        return ""
    }

    public static func encodeTrainingSettings(_ settings: TrainingSettingsDataModel) -> String {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(settings)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            Global.log.error("Error encoding training settings: \(error)")
        }
        return ""
    }

    public static func encodeTrainingPlan(_ monthlyData: [YearMonth: MonthlyTrainingData]) -> String? {
        let encodedMonthlyData = monthlyData.map { key, value in
            [key.toCache(): MonthlyTrainingDataDocument(value)]
        }
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(encodedMonthlyData)
            return String(data: data, encoding: .utf8)
        } catch {
            Global.log.error("Error encoding training plan: \(error)")
        }
        return nil
    }

    public static func decodeTrainingDayType(_ data: String) -> [YearMonthDay: DailyTrainingData] {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedData = try decoder.decode([TrainingGenerationDayType].self, from: data.data(using: .utf8)!)
            print("Decoded data: \(decodedData)")
        } catch {
            Global.log.error("Error decoding training day type: \(error)")
        }
        return [:]
    }

    public static func decodeTrainingPlan(_ data: String) -> [YearMonth: MonthlyTrainingData] {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedData = try decoder.decode([MonthlyTrainingDataDocument].self, from: data.data(using: .utf8)!)
            print("Decoded data: \(decodedData)")
//            return decodedData.reduce(into: [:]) { dict, data in
//                dict[YearMonth.fromCache(data.key)] = data.value.toMonthlyTrainingData()
//            }
//            return [:]
        } catch {
            Global.log.error("Error decoding training plan: \(error)")
        }
        return [:]
    }

    // The output will be like:
//       {
//           "2021-08-01": {
//               "workout": {
//                   "type": "time",
//                   "time": 3600
//               }
//           },
//           "2021-08-02": {
//               "workout": {
//                   "type": "distance",
//                    "distance": 10000
//               }
//           }
//       }
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
