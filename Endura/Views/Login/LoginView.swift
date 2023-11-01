import Foundation
import SwiftUI
import WidgetKit

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
            VStack(alignment: .center, spacing: 10) {
                Image("EnduraLogo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(16)

                Spacer()
                    .frame(height: 3)

                Text("Welcome to Endura!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))

                VStack(spacing: 20) {
                    VStack {
                        Text("Email")
                            .foregroundColor(Color(red: 0.26, green: 0.33, blue: 0.4))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack {
                        Text("Password")
                            .foregroundColor(Color(red: 0.26, green: 0.33, blue: 0.4))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    Spacer()
                        .frame(height: 3)

                    Button {
                        viewModel.login()
                        print("Sign in tapped")
                    } label: {
                        Text("Sign in")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(EnduraNewButtonStyle())
//            .disabled(!viewModel.validateInput())
//            .padding(.horizontal, 24)
//            .padding(.vertical, 16)
//            .frame(maxWidth: .infinity, alignment: .top)
//            .background(Color(red: 0, green: 0.68, blue: 0.68))
//            .cornerRadius(8)
//            .disabled(!viewModel.validateInput())
//            .shadow(color: Color(hex: "008A8A").opacity(1), radius: 0, x: 0, y: 7)
                }
                .padding(40)

                HStack(spacing: 0) {
                    Text("Don’t have an account? ")
                        .font(
                            Font.custom("Inter", size: 14)
                                .weight(.semibold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.48, green: 0.48, blue: 0.62))

                    NavigationLink(destination: SignupView()) {
                        Text("Sign up.")
                            .font(
                                Font.custom("Inter", size: 14)
                                    .weight(.semibold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(.accentColor)
                    }
                }
                .frame(width: 393, alignment: .top)
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
