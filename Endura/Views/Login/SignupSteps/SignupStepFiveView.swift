import Foundation
import SwiftUI

struct SignupStepFiveView: View {
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
                Image(systemName: "person.text.rectangle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color.accentColor)

                Text("Tell us about yourself")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))

                Text("We use your weight to generate your workout plans.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextMuted"))

                VStack(spacing: 0) {
                    Text("Weight")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    Picker("Weight", selection: Binding(
                        get: { viewModel.weight },
                        set: { viewModel.weight = $0 }
                    )) {
                        ForEach(0 ..< 300) { index in
                            Text("\(Double(index).removeTrailingZeros()) lbs")
                                .foregroundColor(Color("Text"))
                                .font(.title3)
                                .tag(Double(index))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .scaledToFit()
                    .labelsHidden()
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
            .padding([.horizontal, .top], 40)
            .padding(.bottom, 10)
        }
    }
}
