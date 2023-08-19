//
// Created by Tobin Palmer on 8/15/23.
//

import Foundation

import SwiftUI

struct ActivityGridStats: View {
    private let activityData: ActivityData?
    private let topSpace: Bool
    private let bottomSpace: Bool
    private let placeholder: Bool

    public init(activityData: ActivityData?, bottomSpace: Bool = false, topSpace: Bool = false, placeholder: Bool = false) {
        self.activityData = activityData
        self.bottomSpace = bottomSpace
        self.topSpace = topSpace
        self.placeholder = placeholder
    }

    public var body: some View {
        if topSpace {
            Spacer(minLength: 10)
        }

        if placeholder {
            VStack {
                ActivityGridSection {
                    ActivityStatsSection {
                        ActivityStatsDiscriptionText("-------------", block: true)
                        ActivityStatsValueText("----------", block: true)
                    }

                    ActivityStatsVLine()

                    ActivityStatsSection {
                        ActivityStatsDiscriptionText("-------------", block: true)
                        ActivityStatsValueText("----------", block: true)
                    }
                }

                ActivityGridSection {
                    ActivityStatsSection {
                        ActivityStatsDiscriptionText("-------------", block: true)
                        ActivityStatsValueText("----------", block: true)
                    }

                    ActivityStatsVLine()

                    ActivityStatsSection {
                        ActivityStatsDiscriptionText("-------------", block: true)
                        ActivityStatsValueText("----------", block: true)
                    }
                }

                ActivityGridSection {
                    ActivityStatsSection {
                        ActivityStatsDiscriptionText("-------------", block: true)
                        ActivityStatsValueText("----------", block: true)
                    }

                    ActivityStatsVLine()

                    ActivityStatsSection {
                        ActivityStatsDiscriptionText("-------------", block: true)
                        ActivityStatsValueText("----------", block: true)
                    }
                }

                if bottomSpace {
                    Spacer(minLength: 10)
                }
            }
        }

        if let activityData = activityData {
            VStack {
                ActivityGridSection {
                    ActivityStatsSection {
                        ActivityStatsDiscriptionText("Distance")
                        ActivityStatsValueText("\(ConversionUtils.metersToMiles(activityData.distance).rounded(toPlaces: 2)) miles")
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

                    ActivityStatsSection {
                        if let averagePower = activityData.averagePower, averagePower > 0 {
                            ActivityStatsDiscriptionText("Average Power")
                            ActivityStatsValueText("\(ConversionUtils.round(averagePower)) W")
                        }
                    }
                }

                if bottomSpace {
                    Spacer(minLength: 10)
                }
            }
        }
    }
}
