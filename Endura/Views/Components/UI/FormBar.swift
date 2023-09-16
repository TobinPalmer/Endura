import Foundation
import SwiftUI

struct FormBarView: View {
    @Binding private var progress: Int
    private let steps: Int

    init(progress: Binding<Int>, steps: Int) {
        _progress = progress
        self.steps = steps
    }

    public var body: some View {
        HStack {
            ForEach(0 ..< steps, id: \.self) { index in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(index <= progress ? .black : .gray)
            }
        }
    }
}
