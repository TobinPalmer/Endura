import Foundation

public enum ConversionUtils {
    public static func round(_ metersPerSec: Double) -> String {
        String(Int(metersPerSec.rounded()))
    }

    public static func round2(_ metersPerSec: Double) -> String {
        String(metersPerSec.rounded(toPlaces: 2))
    }

    public static func getDefaultActivityName(time: Date) -> String {
        let hour = Calendar.current.component(.hour, from: time)
        var title: String

        switch hour {
        case 0 ..< 12:
            title = "Morning Run"
        case 12 ..< 17:
            title = "Afternoon Run"
        case 17 ..< 24:
            title = "Evening Run"
        default:
            title = "Activity"
        }

        return title
    }

    public static func numberToDayOfWeek(day: Int) -> String {
        switch day {
        case 1:
            return "Monday"
        case 2:
            return "Tuesday"
        case 3:
            return "Wednesday"
        case 4:
            return "Thursday"
        case 5:
            return "Friday"
        case 6:
            return "Saturday"
        case 7:
            return "Sunday"
        default:
            return "Monday"
        }
    }

    public static func convertMpsToMpm(_ metersPerSec: Double) -> String {
        if metersPerSec <= 0 {
            return "0:00"
        }

        let mps = metersPerSec.rounded(toPlaces: 3)

        let metersPerMile = 1609.34
        let secondsPerMinute = 60.0

        let minutesPerMile = 1 / (mps / (metersPerMile / secondsPerMinute))

        guard !minutesPerMile.isNaN || !minutesPerMile.isInfinite else {
            return "0:00"
        }

        let minutes = Int(minutesPerMile)
        let seconds = Int((minutesPerMile - Double(minutes)) * secondsPerMinute)

        let formattedSpeed = String(format: "%d:%02d", minutes, seconds)

        return formattedSpeed
    }

    public static func metersToMiles(_ meters: Double) -> Double {
        meters / 1609.34
    }
}
