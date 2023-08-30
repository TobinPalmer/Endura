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
