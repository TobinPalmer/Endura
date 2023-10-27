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

struct EnduraNewButtonStyle: ButtonStyle {
    private let backgroundColor: Color
    private let color: Color
    private let width: CGFloat
    private let height: CGFloat

    init(
        backgroundColor: Color = Color.accentColor,
        color: Color = Color.white,
        maxWidth: CGFloat = .infinity,
        maxHeight: CGFloat = 30
    ) {
        self.backgroundColor = backgroundColor
        self.color = color
        width = maxWidth
        height = maxHeight
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: width, maxHeight: height)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .foregroundColor(color)
            .fontWeight(.bold)
            .background(configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor)
            .cornerRadius(6)
    }
}

struct EnduraButtonStyle: ButtonStyle {
    private let backgroundColor: Color
    private let disabled: Bool
    private let borderColor: Color

    init(backgroundColor: Color = Color.accentColor, borderColor: Color = Color(hex: "008A8A"),
         disabled: Bool = false)
    {
        self.backgroundColor = backgroundColor
        self.disabled = disabled
        self.borderColor = borderColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(disabled ? Color.gray : backgroundColor)
            .cornerRadius(8)
            .shadow(color: disabled ? Color(hex: "777777") : borderColor, radius: 0, x: 0,
                    y: configuration.isPressed ? 0 : 7)
            .offset(y: configuration.isPressed ? 7 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct EnduraCircleButtonStyle: ButtonStyle {
    private let backgroundColor: Color
    private let shadowColor: Color

    init(backgroundColor: Color = Color.accentColor, shadowColor: Color = Color("008A8A")) {
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(backgroundColor)
            .cornerRadius(500)
            .overlay(
                RoundedRectangle(cornerRadius: 500)
                    .stroke(Color("Border"), lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
