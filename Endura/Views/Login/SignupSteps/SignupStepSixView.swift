import Foundation
import SwiftUI
import WrappingHStack

private final class SignupStepSixViewModel: ObservableObject {
    fileprivate final func numberToDayOfWeek(day: Int) -> String {
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
                                Button("\(stepViewModel.numberToDayOfWeek(day: index))") {
                                    showingDate = index
                                }
                                .fixedSize()
                                .buttonStyle(EnduraButtonStyle(backgroundColor: stepViewModel.stateToColor(state: viewModel.schedule[index - 1].1)))
                                .padding(.vertical, 3)
                            }
                        }

                        VStack {
                            Button("Busy") {
                                viewModel.schedule[showingDate - 1].1 = .BUSY
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].1 != .BUSY) ? .gray : .accentColor))
                            .padding(.vertical, 3)
                            Button("Probably Not") {
                                viewModel.schedule[showingDate - 1].1 = .PROBABLY_NOT
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].1 != .PROBABLY_NOT) ? .gray : .accentColor))
                            .padding(.vertical, 3)
                            Button("Maybe") {
                                viewModel.schedule[showingDate - 1].1 = .MAYBE
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].1 != .MAYBE) ? .gray : .accentColor))
                            .padding(.vertical, 3)
                            Button("Probably") {
                                viewModel.schedule[showingDate - 1].1 = .PROBABLY
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].1 != .PROBABLY) ? .gray : .accentColor))
                            .padding(.vertical, 3)
                            Button("Free") {
                                viewModel.schedule[showingDate - 1].1 = .FREE
                            }
                            .fixedSize()
                            .buttonStyle(EnduraButtonStyle(backgroundColor: (viewModel.schedule[showingDate - 1].1 != .FREE) ? .gray : .accentColor))
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
