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
        ZStack(alignment: .top) {
            Color("Background").edgesIgnoringSafeArea(.all)

            VStack(alignment: .center, spacing: 20) {
                Text("Tell us about yourself")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))

                VStack(spacing: 7) {
                    Text("First Name")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    TextField("", text: $viewModel.firstName)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(spacing: 7) {
                    Text("Last Name")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    TextField("", text: $viewModel.lastName)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(spacing: 7) {
                    Text("Email")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    TextField("", text: $viewModel.email)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(spacing: 7) {
                    Text("Password")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    TextField("", text: $viewModel.password)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                }

                Spacer()

                Button("Next") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(EnduraNewButtonStyle(backgroundColor: (viewModel.firstName.isEmpty || viewModel.lastName
                        .isEmpty) ? .gray : .accentColor))
//                .disabled(viewModel.firstName.isEmpty || viewModel.lastName.isEmpty)
            }
            .padding([.horizontal, .top], 40)
            .padding(.bottom, 10)
        }
    }
}
