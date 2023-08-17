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
        HStack {
            VStack(alignment: .center) {
                Text("Distance")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))

                Text("\(ConversionUtils.metersToMiles(activityData.distance).truncate(places: 2).removeTrailingZeros()) mi")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 20) {
                Divider().frame(width: 1)
            }
            .frame(width: 2, height: 50)

            VStack {
                Text("Duration")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                Text("\(FormattingUtils.secondsToFormattedTime(activityData.duration))")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)

        if bottomSpace {
            Spacer(minLength: 10)
        }
    }
}
