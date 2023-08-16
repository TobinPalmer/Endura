//
// Created by Tobin Palmer on 8/15/23.
//

import Foundation

import SwiftUI

struct ActivityPostStats: View {
    private let distance: Double
    private let duration: Double

    public init(distance: Double, duration: Double) {
        self.distance = distance
        self.duration = duration
    }

    public var body: some View {
        HStack {
            VStack {
                Text("Distance")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))

                Text("\(ConversionUtils.metersToMiles(distance).truncate(places: 2).removeTrailingZeros()) mi")
                    .font(.title3)
            }

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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
