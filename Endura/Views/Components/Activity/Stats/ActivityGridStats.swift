//
// Created by Tobin Palmer on 8/15/23.
//

import Foundation

import SwiftUI

struct ActivityGridStats: View {
    private let activityData: ActivityData
    private let topSpace: Bool
    private let bottomSpace: Bool

    public init(activityData: ActivityData, bottomSpace: Bool = false, topSpace: Bool = false) {
        self.activityData = activityData
        self.bottomSpace = bottomSpace
        self.topSpace = topSpace
    }

    public var body: some View {
        if topSpace {
            Spacer(minLength: 10)
        }

        VStack {
            ActivityGridSection {
                ActivityStatsSection {
                    ActivityStatsDiscriptionText("Distance")
                    ActivityStatsValueText("\(ConversionUtils.metersToMiles(activityData.distance).truncate(places: 2).removeTrailingZeros()) mi")
                }

                ActivityStatsVLine()

                ActivityStatsSection {
                    ActivityStatsDiscriptionText("Duration")
                    ActivityStatsValueText("\(FormattingUtils.secondsToFormattedTime(activityData.duration))")
                }
            }

            ActivityGridSection {
                ActivityStatsSection {
                    ActivityStatsDiscriptionText("Pace")
                    ActivityStatsValueText("\(ConversionUtils.convertMpsToMpm(activityData.pace)) min/mile")
                }

                ActivityStatsSection {
                    ActivityStatsDiscriptionText("Calories")
                    ActivityStatsValueText("\(activityData.calories.truncate(places: 0).removeTrailingZeros()) cal")
                }
            }

            ActivityGridSection {
                ActivityStatsSection {
                    ActivityStatsDiscriptionText("Elapsed Time")
                    ActivityStatsValueText("\(FormattingUtils.secondsToFormattedTime(activityData.totalDuration))")
                }

                ActivityStatsSection {}
            }

            if bottomSpace {
                Spacer(minLength: 10)
            }
        }
    }
}
