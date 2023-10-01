import Foundation
import SwiftUICalendar

public enum FormattingUtils {
    public static func secondsToFormattedTime(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let formattedString = formatter.string(from: TimeInterval(seconds))!
        return formattedString
    }

    public static func fullFormattedDay(_ date: YearMonthDay) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        let formattedString = formatter.string(from: date.getDate())
        return formattedString
    }

    public static func dateToFormattedDay(_ date: YearMonthDay) -> String {
        if date == .current {
            return "Today"
        } else if date == .current.addDay(value: -1) {
            return "Yesterday"
        } else if date == .current.addDay(value: 1) {
            return "Tomorrow"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        let formattedString = formatter.string(from: date.getDate())
        return formattedString
    }
}
