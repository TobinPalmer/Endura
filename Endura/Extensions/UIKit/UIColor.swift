import Foundation
import SwiftUI

public extension UIColor {
    convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        precondition(0 ... 1 ~= hue &&
            0 ... 1 ~= saturation &&
            0 ... 1 ~= lightness &&
            0 ... 1 ~= alpha, "input range is out of range 0...1")

        var newSaturation: CGFloat = 0.0

        let brightness = lightness + saturation * min(lightness, 1 - lightness)

        if brightness == 0 {
            newSaturation = 0.0
        } else {
            newSaturation = 2 * (1 - lightness / brightness)
        }

        self.init(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        adjust(by: -1 * abs(percentage))
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage / 100, 1.0),
                           green: min(green + percentage / 100, 1.0),
                           blue: min(blue + percentage / 100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
