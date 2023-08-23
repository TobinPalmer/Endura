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
    @Published var birthday: Date = .init(timeIntervalSince1970: 946_717_200) // 2000-01-01
    @Published var gender: String = ""
}

struct SignupView: View {
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject fileprivate var viewModel = SignupViewModel()
    @ObservedObject fileprivate var signupFormInfo = SignupFormInfo()

    @State private var currentStep: Int = 0

    var formSteps: [AnyView] {
        var steps = [
            AnyView(SignupStepOneView(viewModel: signupFormInfo, currentStep: $currentStep)),
            AnyView(SignupStepTwoView(viewModel: signupFormInfo, currentStep: $currentStep)),
            AnyView(SignupStepFourView(viewModel: signupFormInfo, currentStep: $currentStep)),
            AnyView(SignupStepFiveView(viewModel: signupFormInfo, currentStep: $currentStep)),
            AnyView(SignupStepSixView(viewModel: signupFormInfo, currentStep: $currentStep)),
            AnyView(SignupStepSevenView(viewModel: signupFormInfo, currentStep: $currentStep)),
        ]
        if !HealthKitUtils.isAuthorized() {
            steps.insert(AnyView(SignupStepThreeView(viewModel: signupFormInfo, currentStep: $currentStep)), at: 2)
        }
        return steps
    }

    var body: some View {
        MultiStepForm(formSteps, viewModel: signupFormInfo, currentPage: $currentStep)
    }
}
