import Foundation
import SwiftUI

struct FormBarView: View {
    @Binding private var progress: Int
    private let steps: Int
    private let width: CGFloat

    init(progress: Binding<Int>, steps: Int, width: CGFloat = UIScreen.main.bounds.width - 20) {
        _progress = progress
        self.steps = steps
        self.width = width
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("BorderLight"))

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.accentColor)
                    .frame(width: width * CGFloat(progress) / CGFloat(steps), height: progress == 0 ? (20 / 2) : 20)
                    .animation(.easeInOut(duration: 0.5), value: progress)

                // Form bar highlight
//                RoundedRectangle(cornerRadius: 15)
//                    .foregroundColor(Color.white.opacity(0.2))
//                    .frame(
//                        width: (width * CGFloat(progress) / CGFloat(steps)) - 20,
//                        height: progress == 0 ? (7 / 2) : 7
//                    )
//                    .offset(y: progress == 0 ? -(5 / 2) : -5)
//                    .zIndex(1)
//                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(width: width, height: 20)
    }
}
