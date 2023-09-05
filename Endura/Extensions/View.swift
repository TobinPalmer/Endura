import Foundation
import SwiftUI

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
}
