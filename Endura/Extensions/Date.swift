import Foundation

public extension Date {
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
