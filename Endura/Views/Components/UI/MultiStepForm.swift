import Foundation
import SwiftUI

struct MultiStepForm<T>: View where T: ObservableObject {
    @ObservedObject private var viewModel: T
    @Binding private var currentPage: Int

    private let steps: [AnyView]

    init(_ steps: [AnyView], viewModel: T, currentPage: Binding<Int>) {
        self.steps = steps
        self.viewModel = viewModel
        _currentPage = currentPage
    }

    public var body: some View {
        VStack {
            FormBarView(progress: $currentPage, steps: steps.count)

            Spacer()

            Group {
                ForEach(0 ..< steps.count, id: \.self) { index in
                    if index == currentPage {
                        steps[index]
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}
