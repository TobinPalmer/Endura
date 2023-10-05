import Foundation
import SwiftUI

public final class TrainingSetupInfo: ObservableObject {}

struct TrainingSetupView: View {
    @EnvironmentObject var navigation: NavigationModel
    @ObservedObject private var signupFormInfo = SignupFormInfo()

    @State private var currentStep: Int = 0

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            MultiStepForm([
                AnyView(TrainingSetupGoalTypeStepView(viewModel: signupFormInfo, currentStep: $currentStep)),
            ], viewModel: signupFormInfo, currentPage: $currentStep)
                .enduraPadding()
        }
    }
}

struct SelectBox<Content: View>: View {
    let content: Content
    @Binding var selected: Bool

    init(selected: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        _selected = selected
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .font(.title)
            .fontWeight(.bold)
            .fontColor(.primary)
            .padding()
            .border(selected ? .clear : Color.accentColor, width: 2)
            .enduraDefaultBox()
            .onTapGesture {
                selected.toggle()
            }
    }
}

struct TrainingSetupGoalTypeStepView: View {
    @ObservedObject var viewModel: SignupFormInfo
    @Binding var currentStep: Int

    @State var selected = false

    var body: some View {
        VStack {
            Text("What is your long-term goal?")
                .font(.title)
                .fontWeight(.bold)
                .fontColor(.primary)
                .padding()

            VStack(spacing: 20) {
                SelectBox(selected: $selected) {
                    VStack {
                        Text("Race")
                        Text("This is for people that")
                    }
                }
                SelectBox(selected: $selected) {
                    Text("Pace")
                }
            }

            Spacer()

            Button(action: {
                currentStep += 1
            }) {
                Text("Next")
            }
        }
    }
}
