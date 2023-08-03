//
// Created by Brandon Kirbyson on 8/2/23.
//

import Foundation
import SwiftUI

struct MultiStepForm: View {
    @State private var currentStep = 0
    private let steps: [AnyView]

    init(_ steps: [AnyView]) {
        self.steps = steps
    }

    var body: some View {
        VStack {
            ProgressView(value: Double(currentStep), total: Double(steps.count))

            Spacer()

            Group {
                ForEach(0..<steps.count, id: \.self) { index in
                    if index == currentStep {
                        steps[index]
                            .transition(.opacity)
                    }
                }
                if (currentStep == steps.count) {
                    Text("Success!")
                }
            }

            Spacer()

            HStack {
                if currentStep > 0 {
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