import Foundation
import SwiftUI

struct NotificationCountView: View {
    @Binding var value: Int
    @State var foreground: Color = .white
    @State var background: Color = .init("EnduraRed")

    private let size = 18.0
    private let x = 24.0
    private let y = 4.0

    var body: some View {
        ZStack {
            Capsule()
                .fill(background)
                .frame(width: size * widthMultplier(), height: size, alignment: .topTrailing)
                .position(x: x, y: y)

            if hasTwoOrLessDigits() {
                Text("\(value)")
                    .foregroundColor(foreground)
                    .font(Font.caption)
                    .position(x: x, y: y)
            } else {
                Text("99+")
                    .foregroundColor(foreground)
                    .font(Font.caption)
                    .frame(width: size * widthMultplier(), height: size, alignment: .center)
                    .position(x: x, y: y)
            }
        }
        .opacity(value == 0 ? 0 : 1)
    }

    /// showing more than 99 might take too much space, rather display something like 99+
    func hasTwoOrLessDigits() -> Bool {
        value < 100
    }

    func widthMultplier() -> Double {
        if value < 10 {
            // one digit
            return 1.0
        } else if value < 100 {
            // two digits
            return 1.5
        } else {
            // too many digits, showing 99+
            return 2.0
        }
    }
}
