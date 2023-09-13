import Foundation
import SwiftUI

public struct EnduraButtonStyle: ButtonStyle {
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

struct EnduraButtonStyle2: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(Color(red: 0, green: 0.68, blue: 0.68))
            .cornerRadius(8)
            .shadow(color: Color(hex: "008A8A"), radius: 0, x: 0, y: configuration.isPressed ? 0 : 7)
            .offset(y: configuration.isPressed ? 7 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
