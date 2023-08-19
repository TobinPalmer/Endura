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

final class SignupFormInfo: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
}

struct SignupView: View {
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject fileprivate var viewModel = SignupViewModel()
    @ObservedObject fileprivate var signupFormInfo = SignupFormInfo()

    @State private var currentStep: Int = 0

    var body: some View {
        MultiStepForm([
            AnyView(SignupStepOneView(viewModel: signupFormInfo, currentStep: $currentStep)),
            AnyView(SignupStepTwoView(viewModel: signupFormInfo, currentStep: $currentStep)),
            AnyView(SignupStepThreeView(viewModel: signupFormInfo, currentStep: $currentStep)),
        ], viewModel: signupFormInfo, currentPage: $currentStep)
    }
}
