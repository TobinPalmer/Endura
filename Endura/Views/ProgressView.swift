//
// Created by Brandon Kirbyson on 7/28/23.
//

import Foundation
import SwiftUI

@MainActor class ProgressDashboardViewModel: ObservableObject {
    @Published var items: [Int] = []
    var currentCount = 0
    let incrementAmount = 5
    let maxIncrementCount = 10
    var currentIncrementCount = 0

    func setup() {
        items = Array(0 ..< 10)
        currentCount = items.count
    }

    func loadMoreContent() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            let range = currentCount ..< (currentCount + incrementAmount)
            items.append(contentsOf: range)
            currentCount += incrementAmount
        } catch is CancellationError {
            print("There was an error, trying to load more content still.")
            let range = currentCount ..< (currentCount + incrementAmount)
            items.append(contentsOf: range)
            currentCount += incrementAmount
        } catch {
            print("Unexpected error: \(error).")
        }
    }
}

struct ProgressDashboardView: View {
    @ObservedObject var viewModel = ProgressDashboardViewModel()

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.items.indices, id: \.self) { index in
                    Text("Item Number \(viewModel.items[index])")
                        .task {
                            if index == viewModel.items.count - 5 {
                                do {
                                    try await viewModel.loadMoreContent()
                                } catch {
                                    print("Failed to load more posts", error.localizedDescription)
                                }
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
