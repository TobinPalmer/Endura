//
// Created by Tobin Palmer on 7/16/23.
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

            NavigationLink(destination: SignupView()) {
                Text("Signup")
            }
        }
        .frame(width: 300, height: 300)
    }
}
