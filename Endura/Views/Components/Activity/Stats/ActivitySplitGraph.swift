import Foundation
import SwiftUI

struct ActivitySplitGraph: View {
    private let split: ActivitySplitsData
    private let fastestSplit: ActivitySplitsData?
    private let width: CGFloat

    public init(split: ActivitySplitsData, fastestSplit: ActivitySplitsData?, width: CGFloat = 200) {
        self.split = split
        self.fastestSplit = fastestSplit
        self.width = width
    }

    public var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: width, height: 20)
                    .foregroundColor(.clear)

                let width = min(width, width * CGFloat(fastestSplit!.pace / split.pace))
                let _ = print(width)

                Rectangle()
                    .frame(maxWidth: width)
                    .foregroundColor(.green)
            }
        }
    }
}
