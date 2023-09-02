import Foundation
import SwiftUI
import WrappingHStack

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
                                .buttonStyle(EnduraButtonStyle(backgroundColor: stepViewModel.stateToColor(state: viewModel.schedule[index - 1].type)))
                                .padding(.vertical, 3)
                            }
                        }

                        VStack {
                            Button("Busy") {
                                viewModel.schedule[showingDate - 1].type = .BUSY
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].type != .BUSY) ? .gray : .accentColor))
                            .padding(.vertical, 3)
                            Button("Probably Not") {
                                viewModel.schedule[showingDate - 1].type = .PROBABLY_NOT
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].type != .PROBABLY_NOT) ? .gray : .accentColor))
                            .padding(.vertical, 3)
                            Button("Maybe") {
                                viewModel.schedule[showingDate - 1].type = .MAYBE
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].type != .MAYBE) ? .gray : .accentColor))
                            .padding(.vertical, 3)
                            Button("Probably") {
                                viewModel.schedule[showingDate - 1].type = .PROBABLY
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].type != .PROBABLY) ? .gray : .accentColor))
                            .padding(.vertical, 3)
                            Button("Free") {
                                viewModel.schedule[showingDate - 1].type = .FREE
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].type != .FREE) ? .gray : .accentColor))
                            .padding(.vertical, 3)
                        }
                    }
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
                    .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.firstName.isEmpty || viewModel.lastName.isEmpty) ? .gray : .accentColor))
//            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
                }
            }
            .padding(40)
        }
    }
}
