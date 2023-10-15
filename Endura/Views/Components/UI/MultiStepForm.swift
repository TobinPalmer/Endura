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
        ZStack(alignment: .top) {
            Color("Background").edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    VStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .frame(maxHeight: 20)
                            }
                        }
                    }
                    .frame(width: 25, height: 25)

                    FormBarView(progress: $currentPage, steps: steps.count, width: UIScreen.main.bounds.width - 50)
                }
            }
            .zIndex(10)

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
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color("Background"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
