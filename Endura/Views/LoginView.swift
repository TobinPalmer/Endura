//
// Created by Tobin Palmer on 7/16/23.
//

import Foundation
import SwiftUI

class Info: ObservableObject {
    @Published var email = ""
    @Published var password = ""
}

struct LoginView: View {
    @EnvironmentObject var navigation: NavigationModel;
    @ObservedObject var info = Info()

    private func login() {
        AuthUtils.loginWithEmail(info.email, info.password)
        navigation.currentView = .HOME
    }

    var body: some View {
        ZStack {
            Color.white
                    .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Login Form 123")
                TextField("Email", text: $info.email)
                TextField("Password", text: $info.password)
                Button {
                    login()
                } label: {
                    Text("Login")
                }
            }
                    .frame(width: 300, height: 300)
        }
    }
}
