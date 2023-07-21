//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation

struct TimeUtils {
    public static func secondsToFormattedTime(seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let formattedString = formatter.string(from: TimeInterval(seconds))!
        return formattedString
    }

    public static func convertMpsToMpm(metersPerSec: Double) -> String {
        let metersPerMile = 1609.34
        let secondsPerMinute = 60.0

        let minutesPerMile = 1 / (metersPerSec / (metersPerMile / secondsPerMinute))

        let minutes = Int(minutesPerMile)
        let seconds = Int((minutesPerMile - Double(minutes)) * secondsPerMinute)

        let formattedSpeed = String(format: "%d:%02d", minutes, seconds)

        return formattedSpeed
    }
}
