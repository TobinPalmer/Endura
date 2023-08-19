//
//  MultiStepForm.swift created on 8/14/23.
//

import Foundation
import SwiftUI

struct MultiStepForm: View {
    @ObservedObject private var viewModel: SignupFormInfo
    private let steps: [AnyView]
    @Binding private var currentPage: Int

    init(_ steps: [AnyView], viewModel: SignupFormInfo, currentPage: Binding<Int>) {
        self.steps = steps
        self.viewModel = viewModel
        _currentPage = currentPage
    }

    var body: some View {
        VStack {
            ProgressView(value: Double(currentPage), total: Double(steps.count))

            Spacer()

            Group {
                ForEach(0 ..< steps.count, id: \.self) { index in
                    if index == currentPage {
                        steps[index]
                            .transition(.opacity)
                    }
                }
                if currentPage == steps.count {
                    SignupFinishedView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}
