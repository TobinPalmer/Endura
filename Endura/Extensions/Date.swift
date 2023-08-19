//
//  Date.swift created on 7/27/23.
//

import Foundation

public extension Date {
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
