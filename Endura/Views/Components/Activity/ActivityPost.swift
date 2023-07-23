//
// Created by Brandon Kirbyson on 7/21/23.
//

import Foundation
import SwiftUI

struct ActivityPost: View {
    @StateObject var userDataModel = UserDataModel();
    private var activity: ActivityData

    init(activity: ActivityData) {
        self.activity = activity
    }

    var body: some View {
        VStack {
            ProfileImage(uid: activity.uid)
            Text("\(userDataModel.userData?.name ?? "Loading...")")
            Text("\(activity.distance)")
        }
                .task {
                    await userDataModel.getData(uid: activity.uid)
                }
    }
}