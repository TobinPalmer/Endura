import Foundation
import SwiftUICalendar

public enum FormattingUtils {
    public static func secondsToFormattedTime(_ seconds: Double, _ short: Bool = true) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = short ? .abbreviated : .full
        let formattedString = formatter.string(from: TimeInterval(seconds))!
        return formattedString
    }

    public static func secondsToFormattedTimeColon(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        let formattedString = formatter.string(from: TimeInterval(seconds))!

        let regex = try! NSRegularExpression(pattern: "^0+:", options: [])
        let range = NSRange(location: 0, length: formattedString.count)
        let formattedString2 = regex.stringByReplacingMatches(
            in: formattedString,
            options: [],
            range: range,
            withTemplate: ""
        )
        return formattedString2
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

    public static func formatMiles(_ miles: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: miles))!
    }
}
