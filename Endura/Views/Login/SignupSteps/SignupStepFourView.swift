import Foundation
import SwiftUI

struct SignupStepFourView: View {
    @ObservedObject private var viewModel: SignupFormInfo
    @Binding private var currentStep: Int

    @State private var weightPopup = false

    init(viewModel: SignupFormInfo, currentStep: Binding<Int>) {
        _viewModel = ObservedObject(initialValue: viewModel)
        _currentStep = currentStep
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color("Background").edgesIgnoringSafeArea(.all)

            VStack(alignment: .center, spacing: 20) {
//        Image(systemName: "person.crop.circle.fill")
//          .resizable()
//          .frame(width: 150, height: 150)
//          .aspectRatio(contentMode: .fill)
//          .foregroundColor(Color.accentColor)
//
//        Text("Give permissions")
//          .font(.largeTitle)
//          .fontWeight(.bold)
//          .foregroundColor(Color("Text"))
//
//        Text("We need permissions to access your health data so that you can upload workouts from your watch.")
//          .font(.caption)
//          .fontWeight(.bold)
//          .foregroundColor(Color("TextMuted"))

                var birthdayRange: ClosedRange<Date> {
                    let min = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
                    let max = Calendar.current.date(byAdding: .year, value: -8, to: Date())!
                    return min ... max
                }

                VStack(spacing: 0) {
                    Text("Birthday")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    DatePicker(
                        "Birthday",
                        selection: $viewModel.birthday,
                        in: birthdayRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                }

                HStack(spacing: 7) {
                    Text("Gender")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    Picker("Gender", selection: $viewModel.gender) {
                        Text("Other").tag(UserGender.OTHER)
                        Text("Male").tag(UserGender.MALE)
                        Text("Female").tag(UserGender.FEMALE)
                    }
                    .pickerStyle(.menu)
                }

                HStack(spacing: 7) {
                    Text("Weight")
                        .foregroundColor(Color("TextMuted"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)

                    Button {
                        weightPopup = true
                    } label: {
                        Text("\(viewModel.weight.removeTrailingZeros()) lbs")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .popover(isPresented: $weightPopup) {
                        Picker("Weight", selection: Binding(
                            get: { viewModel.weight },
                            set: { viewModel.weight = $0 }
                        )) {
                            ForEach(50 ..< 400) { index in
                                Text("\(Double(index).removeTrailingZeros()) lbs")
                                    .foregroundColor(Color("Text"))
                                    .font(.title3)
                                    .tag(Double(index))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .presentationCompactAdaptation(.popover)
                    }
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
