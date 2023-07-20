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
}
