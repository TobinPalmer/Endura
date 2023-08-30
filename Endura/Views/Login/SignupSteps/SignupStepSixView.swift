import Foundation
import SwiftUI
import WrappingHStack

private final class SignupStepSixViewModel: ObservableObject {
    fileprivate func numberToDayOfWeek(day: Int) -> String {
        switch day {
        case 1:
            return "Monday"
        case 2:
            return "Tuesday"
        case 3:
            return "Wednesday"
        case 4:
            return "Thursday"
        case 5:
            return "Friday"
        case 6:
            return "Saturday"
        case 7:
            return "Sunday"
        default:
            return "Monday"
        }
    }
}

struct SignupStepSixView: View {
    @StateObject private var viewModel: SignupFormInfo
    @StateObject private var stepViewModel = SignupStepSixViewModel()
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
                WrappingHStack(1 ... 7, id: \.self) { index in
                    Button("\(stepViewModel.numberToDayOfWeek(day: index))") {}
                        .fixedSize()
                        .buttonStyle(EnduraButtonStyle())
                        .padding(3)
                }

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
//            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
                }
            }
            .padding(40)
        }
    }
}
