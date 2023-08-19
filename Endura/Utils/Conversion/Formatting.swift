//
//  Formatting.swift created on 7/29/23.
//

import Foundation

public enum FormattingUtils {
    public static func secondsToFormattedTime(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let formattedString = formatter.string(from: TimeInterval(seconds))!
        return formattedString
    }
}
