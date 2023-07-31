//
// Created by Brandon Kirbyson on 7/28/23.
//

import Foundation
import SwiftUI

import SwiftUI

struct ProgressDashboardView: View {
    @ObservedObject var viewModel = ProgressDashboardViewModel()

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.items.indices, id: \.self) { index in
                    Text("Item Number \(viewModel.items[index])")
                        .onAppear {
                            if index == viewModel.items.count - 5 {
                                viewModel.loadMoreContent()
                            }
                        }
                        .frame(height: 250)
                }
            }
        }
            .onAppear {
                viewModel.setup()
            }
    }
}

class ProgressDashboardViewModel: ObservableObject {
    @Published var items: [Int] = []
    var currentCount = 0
    let incrementAmount = 5
    let maxIncrementCount = 10
    var currentIncrementCount = 0

    func setup() {
        items = Array(0..<30)
        currentCount = items.count
    }

    func loadMoreContent() {
        print("Loading more context for \(currentCount)")
        let range = currentCount..<(currentCount + incrementAmount)
        items.append(contentsOf: range)
        currentCount += incrementAmount
    }
}
