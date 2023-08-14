//
// Created by Tobin Palmer on 8/2/23.
//

import Foundation
import SwiftUI

private final class SignupViewModel: ObservableObject {
//    func login() {
//        AuthUtils.loginWithEmail(email, password)
//    }
}

internal final class SignupFormInfo: ObservableObject {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
}

struct SignupView: View {
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject fileprivate var viewModel = SignupViewModel()
    @ObservedObject fileprivate var signupFormInfo = SignupFormInfo()

    var body: some View {
        MultiStepForm([
            AnyView(SignupStepOneView(viewModel: signupFormInfo)),
            AnyView(SignupStepTwoView(viewModel: signupFormInfo)),
            AnyView(SignupStepThreeView(viewModel: signupFormInfo)),
        ], viewModel: signupFormInfo)
    }
}
