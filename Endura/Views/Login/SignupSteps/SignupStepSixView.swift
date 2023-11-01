import Foundation
import SwiftUI

// import WrappingHStack

private final class SignupStepSixViewModel: ObservableObject {
    fileprivate final func stateToColor(state: RunningScheduleType) -> Color {
        switch state {
        case .FREE:
            return Color("EnduraGreen")
        case .BUSY:
            return Color("EnduraRed")
        case .MAYBE:
            return Color("EnduraOrange")
        case .PROBABLY:
            return Color("EnduraYellow")
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
                ForEach(0 ..< 7) { day in
                    Toggle("\(WeekDay(rawValue: day)!.getShortName())", isOn: Binding(
                        get: {
                            viewModel.schedule[day].type == .FREE
                        },
                        set: { newValue in
                            viewModel.schedule[day].type = newValue ? .FREE : .BUSY
                        }
                    ))
                }

                Spacer()

                HStack {
                    Button {
                        withAnimation {
                            currentStep -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(Color("Text"))
                    }
                    .buttonStyle(EnduraNewButtonStyle(maxWidth: 50, maxHeight: 30))

                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(EnduraNewButtonStyle(
                        backgroundColor: (viewModel.firstName.isEmpty || viewModel.lastName
                            .isEmpty) ? .gray : .accentColor,
                        maxHeight: 30
                    ))
                }
            }
        }
        .padding([.horizontal, .top], 40)
        .padding(.bottom, 10)
    }
}
