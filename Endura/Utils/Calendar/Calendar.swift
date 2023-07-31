//
// Created by Brandon Kirbyson on 7/26/23.
//

import Foundation

public struct CalendarUtils {
    public static func generateCurrentMonthDates() -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()))
        guard let startDateOfMonth = calendar.date(from: dateComponents) else {
            return []
        }

        guard let range = calendar.range(of: .day, in: .month, for: startDateOfMonth) else {
            return []
        }

        let startDayOfWeek = startDateOfMonth.dayOfWeek
        let startOffset = startDayOfWeek == 1 ? 0 : startDayOfWeek - 1 // adjusting start offset
        let startOffsetDates = self.dates(for: startOffset, from: startDateOfMonth, in: calendar, isStartOffset: true)

        dates.append(contentsOf: startOffsetDates) // add offset dates to the start

        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startDateOfMonth) {
                dates.append(date)
            }
        }

        let totalDaysAdded = dates.count
        let remainingDaysInWeek = totalDaysAdded % 7 == 0 ? 0 : 7 - (totalDaysAdded % 7) // calculating end offset

        let endOffsetDates = self.dates(for: remainingDaysInWeek, from: dates.last ?? startDateOfMonth, in: calendar, isStartOffset: false)
        dates.append(contentsOf: endOffsetDates) // add offset dates to the end

        return dates
    }

    private static func dates(for offset: Int, from startDate: Date, in calendar: Calendar, isStartOffset: Bool) -> [Date] {
        var result: [Date] = []
        for i in 1...offset {
            let dateComponents = DateComponents(day: isStartOffset ? -i : i)
            if let date = calendar.date(byAdding: dateComponents, to: startDate) {
                result.append(date)
            }
        }
        return isStartOffset ? result.reversed() : result  // reversing only for start offset dates
    }
}