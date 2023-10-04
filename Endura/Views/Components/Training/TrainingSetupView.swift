import Foundation
import SwiftUI

public final class TrainingSetupInfo: ObservableObject {}

struct TrainingSetupView: View {
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject private var signupFormInfo = SignupFormInfo()

    @State private var currentStep: Int = 0

    var body: some View {
        MultiStepForm([
            AnyView(TrainingSetupStepOneView(viewModel: signupFormInfo, currentStep: $currentStep)),
        ], viewModel: signupFormInfo, currentPage: $currentStep)
    }
}

struct TrainingSetupStepOneView: View {
    @ObservedObject var viewModel: SignupFormInfo
    @Binding var currentStep: Int

    var body: some View {
        VStack {}
    }
}
