import Foundation
import SwiftUI

public enum EnduraFontColor {
    case primary
    case secondary
    case muted
}

public extension View {
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.renderedImage
    }

    func shadowDefault(disabled: Bool = false) -> some View {
        let color = Color(red: 0.2, green: 0.2, blue: 0.28).opacity(0.2)

        return shadow(color: disabled ? .clear : color, radius: 0.5, x: 0, y: 0)
            .shadow(color: disabled ? .clear : color, radius: 1, x: 0, y: 1)
    }

    func newShadow() -> some View {
        shadow(color: Color(red: 0.2, green: 0.2, blue: 0.28).opacity(0.08), radius: 10, x: 0, y: 4)
            .shadow(color: Color(red: 0.05, green: 0.1, blue: 0.29).opacity(0.1), radius: 0.5, x: 0, y: 0)
    }

    func EnduraDefaultBox() -> some View {
        background(.white)
            .cornerRadius(16)
            .newShadow()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.2, green: 0.2, blue: 0.28).opacity(0.1), lineWidth: 1)
            )
    }

    func fontColor(_ fontColor: EnduraFontColor) -> some View {
        switch fontColor {
        case .primary:
            foregroundColor(Color("Text"))
        case .secondary:
            foregroundColor(Color("TextSecondary"))
        case .muted:
            foregroundColor(Color("TextMuted"))
        }
    }
}
