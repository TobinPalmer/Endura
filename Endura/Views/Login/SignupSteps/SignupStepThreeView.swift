//
// Created by Tobin Palmer on 8/13/23.
//

import Foundation

import SwiftUI

struct SignupStepThreeView: View {
    @ObservedObject private var viewModel: SignupFormInfo
    @Binding private var currentPage: Int

    init(viewModel: SignupFormInfo, currentStep: Binding<Int>) {
        _viewModel = ObservedObject(initialValue: viewModel)
        _currentPage = currentStep
    }

    public var body: some View {
        VStack {}

        Button("Back") {
            withAnimation {
                currentPage -= 1
            }
        }
    }
}
