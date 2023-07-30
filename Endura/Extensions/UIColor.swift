//
// Created by Brandon Kirbyson on 7/30/23.
//

import Foundation
import SwiftUI

public extension UIColor {
    convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        precondition(0...1 ~= hue &&
                0...1 ~= saturation &&
                0...1 ~= lightness &&
                0...1 ~= alpha, "input range is out of range 0...1")

        var newSaturation: CGFloat = 0.0

        let brightness = lightness + saturation * min(lightness, 1 - lightness)

        if brightness == 0 {
            newSaturation = 0.0
        } else {
            newSaturation = 2 * (1 - lightness / brightness)
        }

        self.init(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
}
