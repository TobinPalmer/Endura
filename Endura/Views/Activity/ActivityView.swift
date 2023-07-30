//
// Created by Brandon Kirbyson on 7/28/23.
//

import Foundation
import SwiftUI

public struct ActivityView: View {
    private var id: String
    private var activity: ActivityData
    @State var activityData: ActivityDataWithRoute?

    public init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    public var body: some View {
        VStack {
            if let activityData = activityData {
                VStack {
                    HStack {
                        Text("\(ConversionUtils.metersToMiles(activityData.distance))")
                        Text("\(FormattingUtils.secondsToFormattedTime(seconds: activityData.duration))")
                    }
                }
            }
        }
                .task {
                    activityData = await activity.withRouteData(id: id)
                }
    }

}
