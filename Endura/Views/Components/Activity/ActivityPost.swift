//
// Created by Brandon Kirbyson on 7/21/23.
//

import Foundation
import SwiftUI

struct ActivityPost: View {
    @State var activity: String

    init(activity: String) {
        self.activity = activity
    }

    var body: some View {
        VStack {
            Text(activity)
        }
    }
}