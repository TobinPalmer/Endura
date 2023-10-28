import Foundation
import SwiftUI

struct ActivityPostStats: View {
    private let distance: Double
    private let duration: Double
    private let pace: Double

    public init(activityData: ActivityData) {
        distance = activityData.distance
        duration = activityData.duration
        pace = activityData.pace
    }

    public init(distance: Double, duration: Double) {
        self.distance = distance
        self.duration = duration
        if distance == 0 || duration == 0 {
            pace = 0
        } else {
            pace = duration / distance
        }
    }

    public var body: some View {
        HStack {
            ActivityStatsSection {
                ActivityStatsDiscriptionText("Distance")
                ActivityStatsValueText(
                    "\(ConversionUtils.metersToMiles(distance).rounded(toPlaces: 2)) miles"
                )
            }

            ActivityStatsVLine()

            ActivityStatsSection {
                ActivityStatsDiscriptionText("Duration")
                ActivityStatsValueText("\(FormattingUtils.secondsToFormattedTime(duration))")
            }

            ActivityStatsVLine()

            ActivityStatsSection {
                ActivityStatsDiscriptionText("Pace")
                ActivityStatsValueText("\(ConversionUtils.convertMpsToMpm(pace)) min/mile")
            }
        }
    }
}
