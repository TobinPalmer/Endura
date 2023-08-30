import Foundation
import SwiftUI

struct SignupStepFourView: View {
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
                var birthdayRange: ClosedRange<Date> {
                    let min = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
                    let max = Calendar.current.date(byAdding: .year, value: -8, to: Date())!
                    return min ... max
                }

                DatePicker("Birthday", selection: $viewModel.birthday, in: birthdayRange, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxHeight: 400)

                Picker("Flavor", selection: $viewModel.gender) {
                    Text("Male")
                    Text("Female")
                    Text("Other")
                }
                .pickerStyle(.inline)

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
//                    .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
                }
            }
            .padding(40)
        }
    }
}
