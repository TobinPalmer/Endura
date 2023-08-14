//
// Created by Brandon Kirbyson on 8/2/23.
//

import Foundation
import SwiftUI

struct MultiStepForm: View {
    @ObservedObject private var viewModel: SignupFormInfo
    @State private var currentStep = 0
    private let steps: [AnyView]

    init(_ steps: [AnyView], viewModel: SignupFormInfo) {
        self.steps = steps
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            ProgressView(value: Double(currentStep), total: Double(steps.count))

            Spacer()

            Group {
                ForEach(0 ..< steps.count, id: \.self) { index in
                    if index == currentStep {
                        steps[index]
                            //                            .environmentObject(formInfo)
                            .transition(.opacity)
                    }
                }
                if currentStep == steps.count {
                    Text("Success!")
                    Text("First Name: \(viewModel.firstName)")
                }
            }

            Spacer()

            HStack {
                if currentStep > 0 && currentStep < steps.count {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                }
                Spacer()
                if currentStep < steps.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                } else {
                    Button("Submit") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
            }
        }
    }
}
