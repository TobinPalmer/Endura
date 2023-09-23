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
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("BorderLight"))

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.accentColor)
                    .frame(width: 200 * CGFloat(progress) / CGFloat(steps), height: 30)
                    .animation(.easeInOut, value: progress)

                // Form bar highlight
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color.white.opacity(0.2))
                    .frame(width: (200 * CGFloat(progress) / CGFloat(steps)) - 20, height: 7)
                    .offset(y: -5)
                    .zIndex(1)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(width: 200, height: 30)
    }
}
