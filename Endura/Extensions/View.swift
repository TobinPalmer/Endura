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
        shadow(color: Color("TextMuted").opacity(0.2), radius: 4, x: 0, y: 0)
            .shadow(color: Color("TextMuted").opacity(0.06), radius: 10, x: 0, y: 0)
    }

    func enduraDefaultBox() -> some View {
        background(.white)
            .cornerRadius(16)
            .newShadow()
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color(red: 0.2, green: 0.2, blue: 0.28).opacity(0.1), lineWidth: 1.5)
//            )
    }

    func alignFullWidth(_ alignment: Alignment = .leading) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }

    func enduraPadding() -> some View {
        padding(.horizontal, 24)
            .padding(.vertical, 20)
    }

    func fontColor(_ fontColor: EnduraFontColor = .primary) -> some View {
        switch fontColor {
        case .primary:
            return foregroundColor(Color("Text"))
        case .secondary:
            return foregroundColor(Color("TextSecondary"))
        case .muted:
            return foregroundColor(Color("TextMuted"))
        }
    }
}
