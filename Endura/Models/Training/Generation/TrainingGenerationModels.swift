import Foundation
import SwiftUICalendar

public struct TrainingGenerationDayType: Codable {
    public let date: String
    public var day: YearMonthDay {
        YearMonthDay.fromCache(date)
    }

    public let type: TrainingDayType
}
