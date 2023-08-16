//
// Created by Tobin Palmer on 8/15/23.
//

import Foundation
import SwiftUI

private struct VLine: View {
    var body: some View {
        HStack(spacing: 1) {
            Divider().frame(width: 1)
        }
        .frame(width: 1, height: 30)
    }
}

struct ActivityPostStats: View {
    private let distance: Double
    private let duration: Double
    private let pace: Double

    public init(distance: Double, duration: Double, pace: Double) {
        self.distance = distance
        self.duration = duration
        self.pace = pace
    }

    public var body: some View {
        HStack {
            VStack {
                Text("Distance")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                    .minimumScaleFactor(0.5)

                Text("\(ConversionUtils.metersToMiles(distance).truncate(places: 2).removeTrailingZeros()) mi")
                    .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)

            VLine()

            VStack {
                Text("Duration")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                    .minimumScaleFactor(0.5)

                Text("\(FormattingUtils.secondsToFormattedTime(duration))")
                    .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)

            VLine()

            VStack {
                Text("Pace")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                    .minimumScaleFactor(0.5)

                Text("\(ConversionUtils.convertMpsToMpm(pace)) min/mile")
                    .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
