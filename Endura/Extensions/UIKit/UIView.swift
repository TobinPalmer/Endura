//
//  UIView.swift created on 8/1/23.
//

import Foundation
import SwiftUI

public extension UIView {
    var renderedImage: UIImage {
        // rect of capure
        let rect = bounds
        // create the context of bitmap
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}
