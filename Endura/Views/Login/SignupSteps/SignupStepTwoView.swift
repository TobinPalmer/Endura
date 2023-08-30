import Foundation
import SwiftUI

struct SignupStepTwoView: View {
    @StateObject private var viewModel: SignupFormInfo
    @Binding private var currentStep: Int

    init(viewModel: SignupFormInfo, currentStep: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _currentStep = currentStep
    }

    public var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .center, spacing: 20) {
                TextField("Email", text: $viewModel.email)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(EnduraTextFieldStyle())

                TextField("Password", text: $viewModel.password)
                    .textFieldStyle(EnduraTextFieldStyle())

                HStack {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(EnduraButtonStyle())

                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.firstName.isEmpty || viewModel.lastName.isEmpty) ? .gray : .accentColor))
//                    .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
                }
            }
            .padding(40)
        }
    }
}
