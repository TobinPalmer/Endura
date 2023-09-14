import Foundation
import SwiftUICalendar

public extension Date {
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
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

public extension YearMonthDay {
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
