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
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .center, spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.accentColor)

                TextField("First Name", text: $viewModel.firstName)
                    .disableAutocorrection(true)
                    .textFieldStyle(EnduraTextFieldStyle())

                TextField("Last Name", text: $viewModel.lastName)
                    .disableAutocorrection(true)
                    .textFieldStyle(EnduraTextFieldStyle())

                Button("Next") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .buttonStyle(EnduraButtonStyleOld(backgroundColor: (viewModel.firstName.isEmpty || viewModel.lastName.isEmpty) ? .gray : .accentColor))
//                .disabled(viewModel.firstName.isEmpty || viewModel.lastName.isEmpty)
            }
            .padding(40)
        }
    }
}
