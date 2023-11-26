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

    public static func decodeDailyTrainingData(_ data: String, pace: Double,
                                               goalDist _: Double) -> [DailyTrainingData]
    {
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
//            print("goal pace", goalPace)
//            let mps = goalPace.rounded(toPlaces: 3)
//            let metersPerMile = 1609.34
//            let secondsPerMinute = 60.0
//            let pace = 1 / (mps / (metersPerMile / secondsPerMinute))
//            let pace2 = 1 / ((mps * 1609.34) / (metersPerMile / secondsPerMinute))
//            print("pace", pace)
//            print("pace2", pace2)
//            print("pace formatted", ConversionUtils.convertMpsToMpm(goalPace * 1609.34))

            return decodedData.map {
                var dayData = DailyTrainingData.fromDocument($0.value)
                if dayData.goals.isEmpty {
                    return dayData
                }
                switch dayData.goals[0].workout {
                case let .pacer(distance, _):
                    var calculatedPace = pace
                    var dist = distance

                    if distance > 26 {
                        dist = 26
                    }

                    switch dayData.type {
                    case .easy:
                        calculatedPace = pace + calculateEasyPaceFromDistance(dist)
                    case .medium:
                        calculatedPace = pace + calculateEasyPaceFromDistance(dist) - 5
                    case .long:
                        calculatedPace = pace + calculateEasyPaceFromDistance(dist) - 5
                    case .workout:
                        calculatedPace = pace
                    case .none,
                         .rest:
                        break
                    }
                    calculatedPace = (calculatedPace / 5).rounded() * 5
                    print("Pace: \(calculatedPace), Distance: \(distance), Time: \(distance * calculatedPace)")
                    dayData.goals[0].workout = .pacer(distance: distance, time: distance * calculatedPace)
                case .custom,
                     .distance,
                     .open,
                     .time:
                    break
                }
                return dayData
            }
        } catch {}
        return []
    }

    /// Returns the amount that should be added to race pace in order to get easy pace
    private static func calculateEasyPaceFromDistance(_ distance: Double) -> Double {
        let res = 0.513043 * pow(distance, 2) - 17.0522 * distance + 166
        Global.log.info("Distance: \(distance)  res = \(res)")
        return res
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
