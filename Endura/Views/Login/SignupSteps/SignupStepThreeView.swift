import Foundation
import SwiftUI

struct SignupStepThreeView: View {
    @StateObject private var viewModel: SignupFormInfo
    @Binding private var currentStep: Int

    init(viewModel: SignupFormInfo, currentStep: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _currentStep = currentStep
    }

    public var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .center, spacing: 20) {
                Button {
                    HealthKitUtils.requestAuthorization()
                } label: {
                    Text("Give health permissions")
                }
                .disabled(HealthKitUtils.isAuthorized())

                Button {
                    NotificationUtils.requestPermission()
                } label: {
                    Text("Give notification permissions")
                }
                .disabled(NotificationUtils.isAuthorized())

                HStack {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(EnduraButtonStyle())

                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(EnduraButtonStyle(disabled: viewModel.firstName.isEmpty || viewModel.lastName.isEmpty))
//                    .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
                }
            }
            .padding(40)
        }
    }
}
