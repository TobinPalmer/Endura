import Foundation
import SwiftUI

private final class SignupViewModel: ObservableObject {
//    func login() {
//        AuthUtils.loginWithEmail(email, password)
//    }
}

public enum RunningScheduleType: String, Codable {
    case FREE = "free"
    case BUSY = "busy"
    case MAYBE = "maybe"
    case PROBABLY = "probably"
    case PROBABLY_NOT = "probably_not"
}

public struct RunningSchedule: Codable {
    public var day: Int
    public var type: RunningScheduleType
}

public final class SignupFormInfo: ObservableObject {
    @Published public var firstName: String = ""
    @Published public var lastName: String = ""
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var birthday: Date = .init(timeIntervalSince1970: 946_717_200) // 2000-01-01
    @Published public var gender: UserGender = .OTHER
    @Published public var schedule: [RunningSchedule] = (1 ... 7).map { day in
        RunningSchedule(day: day, type: .FREE)
    }

    public func toUserDocument() -> UserDocument {
        UserDocument(
            firstName: firstName,
            lastName: lastName,
            friends: [],
            role: nil,
            birthday: birthday,
            gender: gender,
            email: email
        )
    }

    public func toUserTrainingData() -> UserTrainingData {
        UserTrainingData(schedule: schedule)
    }
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
