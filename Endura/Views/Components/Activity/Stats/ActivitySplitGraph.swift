import Foundation
import SwiftUI

struct ActivitySplitGraph: View {
    private let splits: [ActivitySplitsData]
    private let fastestSplit: ActivitySplitsData
    private let width: CGFloat

    public init(splits: [ActivitySplitsData], width: CGFloat = 200) {
        self.splits = splits
        fastestSplit = splits.min {
            $0.pace < $1.pace
        } ?? ActivitySplitsData(distance: 0, time: 0, pace: 0)
        self.width = width
    }

    public var body: some View {
        VStack {
            Grid {
                ForEach(Array(splits.enumerated()), id: \.1) { index, split in
                    GridRow {
                        GridRow {
                            if split.distance.removeTrailingZeros() == "1" {
                                Text("\(index + 1)")
                            } else {
                                Text("\(split.distance.removeTrailingZeros()) mi")
                            }
                        }

                        GridRow {
                            Text("\(FormattingUtils.secondsToFormattedTime(split.pace))")
                        }

                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: width, height: 20)
                                .foregroundColor(.clear)

                            let width = min(width, width * CGFloat(fastestSplit.pace / split.pace))

                            Rectangle()
                                .frame(maxWidth: width)
                                .foregroundColor(Color("EnduraBlue"))
                        }
                    }
                }
            }
        }
    }
}
