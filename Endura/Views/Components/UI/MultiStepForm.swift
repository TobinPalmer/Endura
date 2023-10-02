import Foundation
import SwiftUI

struct MultiStepForm<T>: View where T: ObservableObject {
    @ObservedObject private var viewModel: T
    @Binding private var currentPage: Int
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private let steps: [AnyView]

    init(_ steps: [AnyView], viewModel: T, currentPage: Binding<Int>) {
        self.steps = steps
        self.viewModel = viewModel
        _currentPage = currentPage
    }

    public var body: some View {
        VStack {
            Spacer()

            Group {
                ForEach(0 ..< steps.count, id: \.self) { index in
                    if index == currentPage {
                        steps[index]
                            .transition(.opacity)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            //                .font(.title)
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxHeight: 20)
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                FormBarView(progress: $currentPage, steps: steps.count, width: UIScreen.main.bounds.width - 75)
            }
        }
    }
}
