//
// Created by Tobin Palmer on 7/20/23.
//

import Foundation
import SwiftUI

//enum CustomTab: CaseIterable {
//    case healthUpload
//    case customUpload
//
//    var title: String {
//        switch self {
//        case .healthUpload:
//            return "Health"
//        case .customUpload:
//            return "Manual"
//        }
//    }
//
//    var icon: String {
//        switch self {
//        case .healthUpload:
//            return "heart.fill"
//        case .customUpload:
//            return "pencil"
//        }
//    }
//}

enum Page {
    case healthUpload
    case customUpload
}

struct UploadWorkoutsFrameView: View {
    @State private var currentPage: Page = .healthUpload
    private var workoutsView = UploadWorkoutView()

    var body: some View {
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
//        VStack(spacing: 0) {
//            HStack(spacing: 0) {
//                ForEach(CustomTab.allCases, id: \.self) { tab in
//                    Button(action: {
//                        selectedTab = tab
//                    }) {
//                        VStack(spacing: 4) {
//                            Image(systemName: tab.icon)
//                                .font(.system(size: 24))
//                                .foregroundColor(selectedTab == tab ? .orange : .gray)
//                            Text(tab.title)
//                                .font(.caption)
//                                .foregroundColor(selectedTab == tab ? .orange : .gray)
//                        }
//                    }
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                }
//            }
//
//            ZStack {
//                switch selectedTab {
//                case .healthUpload:
//                    UploadWorkoutView()
//                case .customUpload:
//                    UploadCustomWorkoutView()
//                }
//            }
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//                .border(Color.red, width: 1)
//        }
    }
}

