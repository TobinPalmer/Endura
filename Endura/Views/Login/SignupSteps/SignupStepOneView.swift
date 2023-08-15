//
// Created by Tobin Palmer on 8/13/23.
//

import Foundation

import SwiftUI

struct SignupStepOneView: View {
    @ObservedObject private var viewModel: SignupFormInfo
    @Binding private var currentStep: Int

    init(viewModel: SignupFormInfo, currentStep: Binding<Int>) {
        _viewModel = ObservedObject(initialValue: viewModel)
        _currentStep = currentStep
    }

    public var body: some View {
        VStack {
            TextField("First Name", text: $viewModel.firstName)
                .textFieldStyle(EnduraTextFieldStyle())

            TextField("Last Name", text: $viewModel.lastName)
                .textFieldStyle(EnduraTextFieldStyle())

            Button("Next") {
                withAnimation {
                    currentStep += 1
                }
            }
            .disabled(viewModel.firstName.isEmpty || viewModel.lastName.isEmpty)
        }
    }
}
