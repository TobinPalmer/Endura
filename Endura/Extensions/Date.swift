//
// Created by Brandon Kirbyson on 7/26/23.
//

import Foundation

extension Date {
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
