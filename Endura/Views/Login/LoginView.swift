import Foundation
import SwiftUI

private enum InputIdentifier {
    case email
    case password
    case both
}

private final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    fileprivate func validateInput(_ input: InputIdentifier = .both) -> Bool {
        switch input {
        case .both:
            return validateInput(.email) && validateInput(.password)
        case .email:
            return email.isValidEmail()
        case .password:
            return password.count >= 6
        }
    }

    func login() {
        if email.isEmpty || password.isEmpty {
            return
        }

        AuthUtils.loginWithEmail(email, password)
    }
}

struct LoginView: View {
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject fileprivate var viewModel = LoginViewModel()

    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 20) {
                Image("EnduraLogo")
                    .resizable()
                    .frame(width: 100, height: 100)

                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))

                TextField("Email", text: $viewModel.email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(EnduraTextFieldStyle())
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .inset(by: 0.5)
                            .stroke(viewModel.validateInput(.email) ? Color("SuccessLight") : .clear, lineWidth: 2)
                    )
                    .shadowDefault(disabled: viewModel.validateInput(.email))
                    .font(
                        Font.custom("Inter", size: 15)
                            .weight(.medium)
                    )
                    .foregroundColor(Color("InputText"))

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(EnduraTextFieldStyle())
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .inset(by: 0.5)
                            .stroke(viewModel.validateInput(.password) ? Color("SuccessLight") : .clear, lineWidth: 2)
                    )
                    .shadowDefault(disabled: viewModel.validateInput(.password))
                    .font(
                        Font.custom("Inter", size: 15)
                            .weight(.medium)
                    )
                    .foregroundColor(Color("InputText"))

                Button {
                    viewModel.login()
                } label: {
                    Text("Login")
                }
                .buttonStyle(EnduraButtonStyle(backgroundColor: (!viewModel.validateInput()) ? .gray : Color("Success")))
                .disabled(!viewModel.validateInput())

                NavigationLink(destination: SignupView()) {
                    Text("Signup")
                }
                .buttonStyle(EnduraButtonStyle())
            }
            .frame(width: .infinity, height: .infinity)
            .padding(40)
        }
    }
}
