//
//  SignupStepThreeView.swift created on 8/14/23.
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
        VStack {
            Text("Is your name \(viewModel.firstName) \(viewModel.lastName)?")
        }

        HStack {
            Button("Back") {
                withAnimation {
                    currentPage -= 1
                }
            }

            Button("Submit") {
                withAnimation {
                    currentPage += 1
                }
            }
        }
    }
}
