//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

public struct UploadCustomWorkoutView: View {
    @EnvironmentObject private var navigation: NavigationModel
    @State private var activities: [ActivityData] = []

    public var body: some View {
        Text("Manual Upload")
    }
}
