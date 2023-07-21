//
// Created by Tobin Palmer on 7/20/23.
//

import Foundation
import SwiftUI

fileprivate enum Page {
    case healthUpload
    case customUpload
}

public struct UploadWorkoutsFrameView: View {
    @State private var currentPage: Page = .healthUpload
    private var workoutsView = UploadWorkoutView()

    public var body: some View {
        VStack {
            Text("Current View, \(String(describing: currentPage))")

            if currentPage == .healthUpload {
                Button(action: {
                    currentPage = .customUpload
                }) {
                    Text("Go to 1")
                }
                workoutsView
            }

            if currentPage == .customUpload {
                Button(action: {
                    currentPage = .healthUpload
                }) {
                    Text("Go to 0")
                }
                UploadCustomWorkoutView()
            }
        }
    }
}

