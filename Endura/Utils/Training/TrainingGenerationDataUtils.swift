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

    public static func encodeTrainingSettings(_ settings: TrainingSettingsDataModel,
                                              _ endGoal: TrainingEndGoalData) -> String
    {
        """
        Paces:
        {
            "easy": \(endGoal.pace + 120)
            "medium": \(endGoal.pace + 90),
            "tempo": \(endGoal.pace + 30),
            "workout": \(endGoal.pace),
        }

        The athlete is FULLY UNAVAILABLE on the following days (these are the ONLY days that should be rest days):
        \(settings.dayAvailabilities.map {
            if let day = WeekDay(rawValue: $0.key) {
                return $0.value ? "" : "\(day.getLongName())"
            }
            return ""
        }
        .filter {
            !$0.isEmpty
        }
        .joined(separator: ", "))

        """
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

    public static func decodeDailyTrainingData(_ data: String) -> [DailyTrainingData] {
        do {
            var cleanedData = data
            if let start = data.firstIndex(of: "{"),
               let end = data.lastIndex(of: "}")
            {
                cleanedData = "\(data[start ... end])"
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedData = try decoder.decode(
                [String: DailyTrainingDataDocument].self,
                from: cleanedData.data(using: .utf8)!
            )
            return decodedData.map {
                DailyTrainingData.fromDocument($0.value)
            }
        } catch {}
        return []
    }

    public static func decodeRoutineData(_ data: String) -> RoutineData? {
        do {
            var cleanedData = data
            if let start = data.firstIndex(of: "{"),
               let end = data.lastIndex(of: "}")
            {
                cleanedData = "\(data[start ... end])"
            }
            print("Cleaned data: \n\n\(cleanedData)\n\n")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedData = try decoder.decode(RoutineData.self, from: cleanedData.data(using: .utf8)!)
            return decodedData
        } catch {
            Global.log.error("Error decoding routine data: \(error)")
        }
        return nil
    }
}
