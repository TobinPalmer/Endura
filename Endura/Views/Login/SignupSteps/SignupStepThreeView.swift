//
// Created by Tobin Palmer on 8/13/23.
//

import Foundation

import SwiftUI

struct SignupStepThreeView: View {
    @ObservedObject private var viewModel: SignupFormInfo;

    init(viewModel: SignupFormInfo) {
        self._viewModel = ObservedObject(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
        }
    }
}

