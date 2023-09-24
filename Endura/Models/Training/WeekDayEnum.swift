import Foundation
import SwiftUICalendar

public enum WeekDay: Int, Codable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6

    public func toYearMonthDay() -> YearMonthDay {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        let date = calendar.date(from: components) ?? Date()
        let day = calendar.date(byAdding: .day, value: rawValue, to: date) ?? Date()
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: day)
        return YearMonthDay(
            year: dayComponents.year ?? 0,
            month: dayComponents.month ?? 0,
            day: dayComponents.day ?? 0
        )
    }

    public static func day(from day: String) -> WeekDay {
        switch day {
        case "Mon",
             "Monday":
            return .monday
        case "Tue",
             "Tuesday":
            return .tuesday
        case "Wed",
             "Wednesday":
            return .wednesday
        case "Thu",
             "Thursday":
            return .thursday
        case "Fri",
             "Friday":
            return .friday
        case "Sat",
             "Saturday":
            return .saturday
        case "Sun",
             "Sunday":
            return .sunday
        default:
            return .monday
        }
    }

    public static func eachDay() -> [WeekDay] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }

    public func getShortName() -> String {
        switch self {
        case .sunday:
            return "Sun"
        case .monday:
            return "Mon"
        case .tuesday:
            return "Tue"
        case .wednesday:
            return "Wed"
        case .thursday:
            return "Thu"
        case .friday:
            return "Fri"
        case .saturday:
            return "Sat"
        }
    }

    public func getLongName() -> String {
        switch self {
        case .sunday:
            return "Sunday"
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        }
    }
}
