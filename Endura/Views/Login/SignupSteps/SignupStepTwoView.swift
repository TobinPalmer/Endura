//
// Created by Tobin Palmer on 8/13/23.
//

import Foundation

import SwiftUI

struct SignupStepTwoView: View {
    @StateObject private var viewModel: SignupFormInfo
    @Binding private var currentPage: Int

    init(viewModel: SignupFormInfo, currentStep: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _currentPage = currentStep
    }

    public var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(EnduraTextFieldStyle())
                .keyboardType(.emailAddress)

            TextField("Password", text: $viewModel.password)
                .textFieldStyle(EnduraTextFieldStyle())

            HStack {
                Button("Back") {
                    withAnimation {
                        currentPage -= 1
                    }
                }

                Button("Next") {
                    withAnimation {
                        currentPage += 1
                    }
                }
                .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
            }
        }
    }
}
