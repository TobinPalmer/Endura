//
// Created by Tobin Palmer on 7/22/23.
//

import Foundation
import MapKit

extension CLLocation: Identifiable {
    public var id: String {
        UUID().uuidString
    }
}
