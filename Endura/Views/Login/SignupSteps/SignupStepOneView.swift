//
// Created by Tobin Palmer on 8/13/23.
//

import Foundation

import SwiftUI

struct SignupStepOneView: View {
    @ObservedObject private var viewModel: SignupFormInfo

    init(viewModel: SignupFormInfo) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            TextField("First Name", text: $viewModel.firstName)
                .textFieldStyle(EnduraTextFieldStyle(systemImageString: "lock"))
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Last Name", text: $viewModel.lastName)
                .textFieldStyle(EnduraTextFieldStyle(systemImageString: "lock"))
        }
    }
}
