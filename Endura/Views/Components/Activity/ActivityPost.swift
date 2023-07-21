//
// Created by Brandon Kirbyson on 7/21/23.
//

import Foundation
import SwiftUI

struct ActivityPost: View {
    private var activity: Activity

    init(activity: Activity) {
        self.activity = activity
    }

    var body: some View {
        VStack {
            Text("\(activity.distance)")
        }
    }
}