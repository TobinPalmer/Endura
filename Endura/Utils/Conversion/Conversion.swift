//
// Created by Brandon Kirbyson on 7/24/23.
//

import Foundation

public struct ConversionUtils {
    public static func convertMpsToMpm(_ metersPerSec: Double) -> String {
        if metersPerSec <= 0 {
            return "0:00"
        }

        let metersPerMile = 1609.34
        let secondsPerMinute = 60.0

        let minutesPerMile = 1 / (metersPerSec / (metersPerMile / secondsPerMinute))

        guard !minutesPerMile.isNaN || !minutesPerMile.isInfinite else {
            return "0:00"
        }

        let minutes = Int(minutesPerMile)
        let seconds = Int((minutesPerMile - Double(minutes)) * secondsPerMinute)

        let formattedSpeed = String(format: "%d:%02d", minutes, seconds)

        return formattedSpeed
    }
}
