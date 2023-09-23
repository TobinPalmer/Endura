import Foundation
import SwiftUI

struct ProgressDashboardView: View {
    @State private var currentPage = 0

    var body: some View {
        VStack {
            NavigationLink(destination: AccountSettingsView()) {
                Text("Account View")
            }

            NavigationLink(destination: PostRunView()) {
                Text("Post Run")
            }

            MultiStepForm([
                AnyView(ExampleStepView(viewModel: ExampleStepViewModel(), currentStep: $currentPage)),
                AnyView(ExampleStepView(viewModel: ExampleStepViewModel(), currentStep: $currentPage)),
                AnyView(ExampleStepView(viewModel: ExampleStepViewModel(), currentStep: $currentPage)),
            ], viewModel: SignupFormInfo(), currentPage: $currentPage)
        }
    }
}

private final class ExampleStepViewModel: ObservableObject {}

struct ExampleStepView: View {
    @ObservedObject private var viewModel = ExampleStepViewModel()
    @Binding private var currentStep: Int

    fileprivate init(viewModel: ExampleStepViewModel, currentStep: Binding<Int>) {
        _viewModel = ObservedObject(initialValue: viewModel)
        _currentStep = currentStep
    }

    public var body: some View {
        VStack {
            Text("Step \(currentStep)")

            Button("Next") {
                withAnimation {
                    currentStep += 1
                }
            }
        }
    }
}
