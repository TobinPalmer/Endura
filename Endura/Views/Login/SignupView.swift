//
// Created by Tobin Palmer on 8/2/23.
//

import Foundation
import SwiftUI

fileprivate final class SignupViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    func login() {
        AuthUtils.loginWithEmail(email, password)
    }
}

struct SignupView: View {
    @EnvironmentObject var navigation: NavigationModel;
    @ObservedObject fileprivate var viewModel = SignupViewModel()

    var body: some View {
        VStack {
            Text("Login")
            LoginTextInput("Email", $viewModel.email)
                .keyboardType(.emailAddress)
            LoginTextInput("Password", $viewModel.password, secure: true)

            Button {
                viewModel.login()
                navigation.currentView = .HOME
            } label: {
                Text("Signup")
            }
        }
            .frame(width: 300, height: 300)
    }
}
