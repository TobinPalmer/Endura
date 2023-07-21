//
// Created by Tobin Palmer on 7/19/23.
//

import Foundation
import SwiftUI
import HealthKit

public struct UploadCustomWorkoutView: View {
    @EnvironmentObject var navigation: NavigationModel
    @State private var activities: [Activity] = []

    public var body: some View {
        Text("Manual Upload")
//        NavigationLink(destination: UploadWorkoutView()) {
//            VStack(alignment: .center) {
//                HStack {
//                    Image(systemName: "pencil")
//                    Text("Upload from health")
//                }
//            }
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
//        }
    }

}
