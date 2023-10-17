import Foundation
import SwiftUI

struct SignupStepTwoView: View {
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
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color.accentColor)

                Text("Create an account")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))

                VStack(spacing: 7) {
                    Text("Email")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    TextField("", text: $viewModel.email)
                        .disableAutocorrection(true)
                        .textFieldStyle(EnduraTextFieldStyle())
                }

                VStack(spacing: 7) {
                    Text("Password")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    TextField("", text: $viewModel.password)
                        .disableAutocorrection(true)
                        .textFieldStyle(EnduraTextFieldStyle())
                }

                Spacer()

                HStack {
                    Button {
                        withAnimation {
                            currentStep -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(Color("Text"))
                    }
                    .buttonStyle(EnduraNewButtonStyle(maxWidth: 50, maxHeight: 30))

                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(EnduraNewButtonStyle(
                        backgroundColor: (viewModel.firstName.isEmpty || viewModel.lastName
                            .isEmpty) ? .gray : .accentColor,
                        maxHeight: 30
                    ))
                }
            }
            .padding([.horizontal, .top], 40)
            .padding(.bottom, 10)
        }
    }
}
