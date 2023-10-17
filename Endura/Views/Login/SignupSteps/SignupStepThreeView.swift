import Foundation
import SwiftUI

struct SignupStepThreeView: View {
    @ObservedObject private var viewModel: SignupFormInfo
    @Binding private var currentStep: Int

    init(viewModel: SignupFormInfo, currentStep: Binding<Int>) {
        _viewModel = ObservedObject(initialValue: viewModel)
        _currentStep = currentStep
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color("Background").edgesIgnoringSafeArea(.all)

            VStack(alignment: .center, spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color.accentColor)

                Text("Give permissions")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))

                Text("We need permissions to access your health data so that you can upload workouts from your watch.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextMuted"))

                Button {
                    HealthKitUtils.requestAuthorization { _ in
                    }
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
            .padding([.horizontal, .top], 40)
            .padding(.bottom, 10)
        }
    }
}
