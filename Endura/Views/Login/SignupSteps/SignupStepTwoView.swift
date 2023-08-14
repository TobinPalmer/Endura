//
// Created by Tobin Palmer on 8/13/23.
//

import Foundation

import SwiftUI

struct SignupStepTwoView: View {
    @ObservedObject private var viewModel: SignupFormInfo

    init(viewModel: SignupFormInfo) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(EnduraTextFieldStyle("lock"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)

            TextField("Password", text: $viewModel.password)
                .textFieldStyle(EnduraTextFieldStyle("lock"))
        }
    }
}
