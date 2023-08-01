//
// Created by Brandon Kirbyson on 8/1/23.
//

import Foundation
import SwiftUI

extension UIImage {
    func crop(to targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / self.size.width
        let heightRatio = targetSize.height / self.size.height

        let scale = widthRatio > heightRatio ? widthRatio : heightRatio

        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgimage = newImage?.cgImage else {
            return nil
        }

        let contextImage: UIImage = UIImage(cgImage: cgimage)

        let posX = (newSize.width - targetSize.width) / 2
        let posY = (newSize.height - targetSize.height) / 2

        let rectToCrop: CGRect = CGRect(x: posX, y: posY, width: targetSize.width, height: targetSize.height)

        guard let imageRef: CGImage = contextImage.cgImage?.cropping(to: rectToCrop) else {
            return nil
        }

        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
}