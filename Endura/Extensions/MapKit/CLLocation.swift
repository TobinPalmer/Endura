//
// Created by Tobin Palmer on 7/22/23.
//

import Foundation
import MapKit

public extension CLLocation: Identifiable {
    public var id: String {
        UUID().uuidString
    }
}
