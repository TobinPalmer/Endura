//
// Created by Brandon Kirbyson on 7/21/23.
//

import Foundation
import SwiftUI

struct ActivityPost: View {
    private var activity: ActivityData

    init(activity: ActivityData) {
        self.activity = activity
    }

    var body: some View {
        VStack {
            ProfileImage(uid: activity.uid)
            Text("\(activity.distance)")
        }
    }
}