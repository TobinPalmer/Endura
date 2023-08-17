//
// Created by Tobin Palmer on 8/15/23.
//

import Foundation
import SwiftUI

struct ActivityPostStats: View {
    private let activityData: ActivityData

    public init(activityData: ActivityData) {
        self.activityData = activityData
    }

    public var body: some View {
        HStack {
            ActivityStatsSection {
                ActivityStatsDiscriptionText("Distance")
                ActivityStatsValueText("\(ConversionUtils.metersToMiles(activityData.distance).truncate(places: 2).removeTrailingZeros()) mi")
            }

            ActivityStatsVLine()

            ActivityStatsSection {
                ActivityStatsDiscriptionText("Duration")
                ActivityStatsValueText("\(FormattingUtils.secondsToFormattedTime(activityData.duration))")
            }

            ActivityStatsVLine()

            ActivityStatsSection {
                ActivityStatsDiscriptionText("Pace")
                ActivityStatsValueText("\(ConversionUtils.convertMpsToMpm(activityData.pace)) min/mile")
            }
        }
    }
}
