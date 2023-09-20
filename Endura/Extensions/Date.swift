import Foundation
import SwiftUICalendar

public extension Date {
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
    }

    func toYearMonthDay() -> YearMonthDay {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return YearMonthDay(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0
        )
    }

    func roundedToNearestSecond() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        return calendar.date(from: components) ?? self
    }

    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
}

public extension YearMonth {
    func toCache() -> String {
        "\(year)-\(month)"
    }

    static func fromCache(_ cachedDate: String) -> YearMonth {
        let components = cachedDate.split(separator: "-")
        return YearMonth(
            year: Int(components[0]) ?? 0,
            month: Int(components[1]) ?? 0
        )
    }
}

public extension YearMonthDay {
    func getYearMonth() -> YearMonth {
        YearMonth(year: year, month: month)
    }

    func toCache() -> String {
        "\(year)-\(month)-\(day)"
    }

    static func fromCache(_ cachedDate: String) -> YearMonthDay {
        let components = cachedDate.split(separator: "-")
        return YearMonthDay(
            year: Int(components[0]) ?? 0,
            month: Int(components[1]) ?? 0,
            day: Int(components[2]) ?? 0
        )
    }
}
