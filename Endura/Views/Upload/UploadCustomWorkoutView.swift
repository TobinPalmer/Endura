//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

struct UploadCustomWorkoutView: View {
    @EnvironmentObject var navigation: NavigationModel
    @State private var activities: [Activity] = []

    var body: some View {
        NavigationLink(destination: UploadWorkoutView()) {
            HStack {
                Image(systemName: "applewatch")
                Text("Normal Workout")
            }
        }
    }
}
