import Foundation
import SwiftUI

public struct EnduraButtonStyleOld:
    ButtonStyle
{
    private let backgroundColor: Color

    init(backgroundColor: Color = Color.accentColor) {
        self.backgroundColor = backgroundColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .animation(.easeInOut(duration: 0.1), value: backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(5)
    }
}

struct EnduraButtonStyle: ButtonStyle {
    private let backgroundColor: Color
    private let disabled: Bool

    init(backgroundColor: Color = Color.accentColor, disabled: Bool = false) {
        self.backgroundColor = backgroundColor
        self.disabled = disabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(disabled ? Color.gray : backgroundColor)
            .cornerRadius(8)
            .shadow(color: disabled ? Color(hex: "777777") : Color(hex: "008A8A"), radius: 0, x: 0, y: configuration.isPressed ? 0 : 7)
            .offset(y: configuration.isPressed ? 7 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
