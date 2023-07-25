//
// Created by Brandon Kirbyson on 7/24/23.
//

import Foundation

public struct ConversionUtils {
    public static func convertMpsToMpm(_ metersPerSec: Double) -> String {
        let metersPerMile = 1609.34
        let secondsPerMinute = 60.0

        let minutesPerMile = 1 / (metersPerSec / (metersPerMile / secondsPerMinute))

        let minutes = Int(minutesPerMile)
        let seconds = Int((minutesPerMile - Double(minutes)) * secondsPerMinute)

        let formattedSpeed = String(format: "%d:%02d", minutes, seconds)

        return formattedSpeed
    }
}