//
// Created by Brandon Kirbyson on 7/21/23.
//

import Foundation
import SwiftUI

struct ActivityPost: View {
    @StateObject var userDataModel = UserDataModel();
    private var activity: ActivityData
    private var id: String

    init(id: String, activity: ActivityData) {
        self.activity = activity
        self.id = id
    }

    var body: some View {
        NavigationLink(destination: ActivityView(id: id, activity: activity)) {
            HStack {
                Text("\(ConversionUtils.metersToMiles(activity.distance))")
                Text("\(FormattingUtils.secondsToFormattedTime(seconds: activity.duration))")
            }
        }
        //        VStack {
        //            ProfileImage(uid: activity.uid)
        //            Text("\(userDataModel.userData?.name ?? "Loading...")")
        //            Text("\(activity.distance)")
        //        }
        //                .task {
        //                    await userDataModel.getData(uid: activity.uid)
        //                }
        //    }
    }
}
