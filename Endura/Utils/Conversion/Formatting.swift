//
// Created by Brandon Kirbyson on 7/24/23.
//

import Foundation

public struct FormattingUtils {
    public static func secondsToFormattedTime(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let formattedString = formatter.string(from: TimeInterval(seconds))!
        return formattedString
    }
}