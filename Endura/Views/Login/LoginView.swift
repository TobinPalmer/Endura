//
//  LoginView.swift created on 8/14/23.
//

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
        VStack {
            Text("Login")

            TextField("Email", text: $viewModel.email)
                .textFieldStyle(EnduraTextFieldStyle())

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(EnduraTextFieldStyle())

            Button {
                viewModel.login()
            } label: {
                Text("Login")
            }
            .buttonStyle(EnduraButtonStyle(disabled: viewModel.email.isEmpty || viewModel.password.isEmpty))
            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)

            NavigationLink(destination: SignupView()) {
                Text("Signup")
            }
            .buttonStyle(EnduraButtonStyle())
        }
        .frame(width: 300, height: 300)
    }
}
