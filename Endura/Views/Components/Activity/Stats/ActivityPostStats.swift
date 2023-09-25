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
                ActivityStatsValueText(
                    "\(ConversionUtils.metersToMiles(activityData.distance).rounded(toPlaces: 2)) miles"
                )
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
