import Foundation
import SwiftUI

struct ActivityPostStats: View {
    private let distance: Double
    private let duration: Double
    private let pace: Double

    public init(activityData: ActivityData) {
        distance = ConversionUtils.metersToMiles(activityData.distance)
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
            Spacer()

            VStack(spacing: 4) {
                HStack {
//                    Image(systemName: "ruler")
                    Text("Distance")
                }
                .font(.caption)
                .fontColor(.muted)
                .fontWeight(.bold)
                Text(
                    "\(FormattingUtils.formatMiles(distance)) mi"
                )
                //                .fontWeight(.semibold)
                .fontColor(.primary)
            }

            Spacer()

            ActivityStatsVLine()

            Spacer()

            VStack(spacing: 4) {
                HStack {
//                    Image(systemName: "timer")
                    Text("Duration")
                }
                .font(.caption)
                .fontColor(.muted)
                .fontWeight(.bold)
                Text("\(FormattingUtils.secondsToFormattedTime(duration))")
                    //                    .fontWeight(.semibold)
                    .fontColor(.primary)
            }

            Spacer()

            ActivityStatsVLine()

            Spacer()

            VStack(spacing: 4) {
                HStack {
//                    Image(systemName: "speedometer")
                    Text("Pace")
                }
                .font(.caption)
                .fontColor(.muted)
                .fontWeight(.bold)
                Text("\(ConversionUtils.convertMpsToMpm(pace)) min/mi")
                    //                    .fontWeight(.semibold)
                    .fontColor(.primary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }
}
