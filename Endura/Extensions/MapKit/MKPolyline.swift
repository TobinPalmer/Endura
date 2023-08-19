//
//  MKPolyline.swift created on 7/30/23.
//

import Foundation
import MapKit
import SwiftUI

private var colorKey: UInt8 = 0

public extension MKPolyline {
    var color: UIColor {
        get {
            objc_getAssociatedObject(self, &colorKey) as? UIColor ?? UIColor.black
        }
        set {
            objc_setAssociatedObject(self, &colorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
