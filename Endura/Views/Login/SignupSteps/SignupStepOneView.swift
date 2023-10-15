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
                Image(systemName: "person.text.rectangle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color.accentColor)

                Text("What's your name?")
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
                        .textFieldStyle(EnduraTextFieldStyle())
                }

                VStack(spacing: 7) {
                    Text("Last Name")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    TextField("", text: $viewModel.lastName)
                        .disableAutocorrection(true)
                        .textFieldStyle(EnduraTextFieldStyle())
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
