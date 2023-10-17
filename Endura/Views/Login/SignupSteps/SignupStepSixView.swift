import Foundation
import SwiftUI

// import WrappingHStack

private final class SignupStepSixViewModel: ObservableObject {
    fileprivate final func stateToColor(state: RunningScheduleType) -> Color {
        switch state {
        case .FREE:
            return .green
        case .BUSY:
            return .red
        case .MAYBE:
            return .orange
        case .PROBABLY:
            return .yellow
        case .PROBABLY_NOT:
            return .gray
        }
    }
}

struct SignupStepSixView: View {
    @StateObject private var viewModel: SignupFormInfo
    @StateObject private var stepViewModel = SignupStepSixViewModel()
    @Binding private var currentStep: Int
    @State private var showingDate: Int = 1

    init(viewModel: SignupFormInfo, currentStep: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _currentStep = currentStep
    }

    public var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .center, spacing: 20) {
                VStack {
                    HStack {
                        VStack {
                            ForEach(1 ... 7, id: \.self) { index in
                                Button("\(ConversionUtils.numberToDayOfWeek(day: index))") {
                                    showingDate = index
                                }
                                .fixedSize()
                                .buttonStyle(EnduraButtonStyleOld(backgroundColor: stepViewModel
                                        .stateToColor(state: viewModel.schedule[index - 1].type)))
                                .padding(.vertical, 3)
                            }
                        }

                        VStack {}
                    }
                }

                HStack {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(EnduraButtonStyleOld())

                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(EnduraButtonStyleOld(backgroundColor: (viewModel.firstName.isEmpty || viewModel
                            .lastName.isEmpty) ? .gray : .accentColor))
//            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
                }
            }
            .padding(40)
        }
    }
}
