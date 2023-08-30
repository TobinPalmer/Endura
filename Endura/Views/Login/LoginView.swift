import Foundation
import SwiftUI

private final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

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

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(EnduraTextFieldStyle())

                Button {
                    viewModel.login()
                } label: {
                    Text("Login")
                }
                .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.email.isEmpty || viewModel.password.isEmpty) ? .gray : .accentColor))
                .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)

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
