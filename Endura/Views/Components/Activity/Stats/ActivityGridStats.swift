//
// Created by Tobin Palmer on 8/15/23.
//

import Foundation

import SwiftUI

struct ActivityGridStats: View {
    private let distance: Double
    private let duration: Double
    private let topSpace: Bool
    private let bottomSpace: Bool

    public init(distance: Double, duration: Double, topSpace: Bool = false, bottomSpace: Bool = false) {
        self.distance = distance
        self.duration = duration
        self.topSpace = topSpace
        self.bottomSpace = bottomSpace
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

                Text("\(ConversionUtils.metersToMiles(distance).truncate(places: 2).removeTrailingZeros()) mi")
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
                Text("\(FormattingUtils.secondsToFormattedTime(duration))")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
